// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract SemiERC1155 is ERC1155URIStorage {
    // Set default uri
    string private constant DEFAULT_URI = "https://";

    // Admin is allowed to call functions on behalf of player
    address public admin;

    // Optional: Maps web2 id to address https://developer.twitter.com/en/docs/twitter-ids
    mapping(uint64 => address) public accounts;

    // Maps player custody. default is false aka player has no custody for better UX
    mapping(address => bool) public playerCustody;

    // Events
    event SetAccount(address indexed _address, uint64 indexed _twitterId);
    event SetCustody(address indexed _address, bool indexed _bool);

    constructor() ERC1155(DEFAULT_URI) {
        admin = msg.sender;
    }

    /*
    * Optional: Conencts address to twitter account. Must set acount before playing
    * @param _address any 0x wallet address where player owns priv key
    * @param _twitterId twitter identifier
    */
    function setAccount(address _address, uint64 _twitterId) public {
        require(msg.sender == admin, "Only admin can set account");
        accounts[_twitterId] = _address;
        emit SetAccount(_address, _twitterId);
    }

    /*
    * Toggles player custody.
    * @param _bool false to disable player custody. Server DOES    control cards. Player DOESN'T pay gas
    * @param _bool true  to enable  player custody. Server DOESN'T control cards. Player DOES    pay gas
    */
    function setCustody(bool _bool) public {
        playerCustody[msg.sender] = _bool;
        emit SetCustody(msg.sender, _bool);
    }

    /*
    * Only admin can mint
    * @param _to address to mint to
    * @param _tokenId token identifier
    * @param _amount of tokens to mint
    * @param _tokenURI uri to metadata json object
    */
    function adminMint(address _to, uint256 _tokenId, uint256 _amount, string memory _tokenURI) public {
        require(msg.sender == admin, "Only admin can mint");
        // if this tokenId has never been minted, then set URI
        if (keccak256(abi.encodePacked(uri(_tokenId))) == keccak256(abi.encodePacked(DEFAULT_URI))) _setURI(_tokenId, _tokenURI);
        _mint(_to, _tokenId, _amount, "");
    }

    /*
    * Only admin with custody can transfer
    * @params _from address. Admin cannot transfer if from address has custody
    * @params _to address to transfer to
    * @params _tokenId token identifier
    * @params _amount of tokens to transfer
    */
    function adminSafeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount) public {
        require(msg.sender == admin, "Only admin can transfer");
        require(playerCustody[_from] == false, "Only admin with custody can transfer");
        _safeTransferFrom(_from, _to, _tokenId, _amount, "");
    }

    /*
    * Only admin with custody can burn
    * @params _from address. Admin cannot burn if from address has custody
    * @params _tokenId token identifier
    * @params _amount of tokens to burn
    */
    function adminBurn(address _from, uint256 _tokenId, uint256 _amount) public {
        require(msg.sender == admin, "Only admin can burn");
        require(playerCustody[_from] == false, "Only admin with custody can burn");
        _burn(_from, _tokenId, _amount);
    }

}
