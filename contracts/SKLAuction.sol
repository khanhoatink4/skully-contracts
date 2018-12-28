pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./AuctionBase.sol";
import "./PO8BaseToken.sol";

/// @title Skully auction for non-fungible tokens;
contract SKLAuction is Pausable, AuctionBase {

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    //    function SKLAuction() public {
    //         ERC721 candidateContract = ERC721();
    //         nonFungibleContract = candidateContract;
    //    }

    // /// @dev Remove all Ether from the contract, which is the owner's cuts
    // ///  as well as any Ether sent directly to the contract address.
    // ///  Always transfers to the NFT contract, but can be called either by
    // ///  the owner or the NFT contract.
    // function withdrawBalance() external {
    //     address nftAddress = address(nonFungibleContract);

    //     require(
    //         msg.sender == owner ||
    //         msg.sender == nftAddress
    //     );
    //     nftAddress.transfer(this.balance);
    // }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    ) public whenNotPaused {
        require(_owns(msg.sender, _tokenId));
        require(_getApproved(address(this), _tokenId));
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId) public payable whenNotPaused {
        // _bid will throw if the bid or funds transfer fails
        address seller = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId, seller);
        PO8BaseToken token = PO8BaseToken(0x1357c8ecb58ba4c193b192b43682cd8edb75e09e);
        token.transferFrom(0xd37AE76bBc61e86a7D643a1291F1f6a951AA2E2B, seller, 5 * 1000000000000000000);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId) public {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId) whenPaused public {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId) public view returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.startingPrice,
        auction.endingPrice,
        auction.duration,
        auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId) public view returns (uint256){
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }
}
