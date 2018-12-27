pragma solidity ^0.4.24;
import "./PO8BaseToken.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";


contract SKLToken is ERC721Full("SKU Token", "SKL"), Ownable {

    using SafeMath for uint256;

    struct Skully {
        uint256 birthTime;
        uint256 genes;
        uint256 attack;
        uint256 defend;
    }

    Skully[] private sklStore;
    bool public isMintable = true;

    modifier mintable {
        require(
            isMintable == true,
            "New skullys are no logger mintable on this contract"
        );
        _;
    }

    event Mint(address _to, uint256 _tokenId);

    /// @dev mint(): mint a new Gen0 skullys. These are the tokens that other skullys will be "closed form".
    /// @param _to address to mint to.
    /// @param _attack attack numeral of the skullys
    /// @param _defend defend numeral of the skullys
    /// @param _genes gen of the skullys
    /// @param _tokenURI A URL to the JSON file containing the metadata for the skullys. See metadata.json for an example.
    /// @return the tokenId of the skullys hash been minted. Note that in a transaction only the tx_hash in returned
    function mint(address _to, uint256 _attack, uint256 _defend, uint256 _genes, string _tokenURI) public mintable onlyOwner returns (uint256 tokenId) {
        Skully memory _sklObj = Skully({
            birthTime: now,
            attack: _attack,
            defend: _defend,
            genes: _genes
            });

        // The new Skully is pushed onto the array and minted
        // note that solidity uses 0 as a default value when an item is not found in a mapping

        tokenId = sklStore.push(_sklObj) - 1;
        _mint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        emit Mint(_to, tokenId);
    }

    /// @dev setMintable(): set the isMintable public variable.  When set to `false`, no new
    ///                     kudos are allowed to be minted or cloned.  However, all of already
    ///                     existing kudos will remain unchanged.
    /// @param _isMintable flag for the mintable function modifier.
    function setMintable(bool _isMintable) public onlyOwner {
        isMintable = _isMintable;
    }


    /// @dev setTokenURI(): Set an existing token URI.
    /// @param _tokenId The token id.
    /// @param _tokenURI The tokenURI string.  Typically this will be a link to a json file on IPFS.
    function setTokenURI(uint256 _tokenId, string _tokenURI) public onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }

    /// @dev getSkullyById(): Return a skullys struct/array given a skullys Id.
    /// @param _tokenId The Skullys Id.
    /// @return the Skullys struct, in array form.
    function getSkullyById(uint256 _tokenId) view public returns (uint256 birthTime, uint256 attack, uint256 defend, uint256 genes)
    {
        Skully memory _sklObj = sklStore[_tokenId];

        attack = _sklObj.attack;
        defend = _sklObj.defend;
        birthTime = _sklObj.birthTime;
        genes = _sklObj.genes;
    }

    /// @dev getLatestId(): Returns the newest skullys Id in the skullys array.
    /// @return the latest skullys id.
    function getLatestId() view public returns (uint256 tokenId)
    {
        if (sklStore.length == 0) {
            tokenId = 0;
        } else {
            tokenId = sklStore.length - 1;
        }
    }
}
