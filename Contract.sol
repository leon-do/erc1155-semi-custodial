// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Dexoshi is ERC1155URIStorage {
    // Set default uri
    string private constant DEFAULT_URI = "@dexoshi";

    // Admin is allowed to call functions on behalf of player
    address private constant ADMIN = 0xdA064B1Cef52e19caFF22ae2Cc1A4e8873B8bAB0;

    constructor() ERC1155(DEFAULT_URI) {}

    /*
    * Only admin can mint
    * @param _to address to transfer to
    * @param _tokenId token identifier
    * @param _amount of tokens to mint
    * @param _tokenURI uri to metadata json object
    */
    function adminMint(address _to, uint256 _tokenId, uint256 _amount, string memory _tokenURI) public {
        require(msg.sender == ADMIN, "Only admin can mint");
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
        require(msg.sender == ADMIN, "Only admin can transfer");
        _safeTransferFrom(_from, _to, _tokenId, _amount, "");
    }

    /*
    * Only admin with custody can batch transfer
    * @params _from address. Admin cannot transfer if from address has custody
    * @params _to address to transfer to
    * @params _tokenIds list of tokens
    * @params _amounts list of amounts
    */
    function adminSafeBatchTransferFrom(address _from, address _to, uint256[] memory _tokenIds, uint256[] memory _amounts) public {
        require(msg.sender == ADMIN, "Only admin can burn");
        _safeBatchTransferFrom(_from, _to, _tokenIds, _amounts, "");
    }

    /*
    * Only admin with custody can burn
    * @params _from address. Admin cannot burn if from address has custody
    * @params _tokenId token identifier
    * @params _amount of tokens to burn
    */
    function adminBurn(address _from, uint256 _tokenId, uint256 _amount) public {
        require(msg.sender == ADMIN, "Only admin can burn");
        _burn(_from, _tokenId, _amount);
    }

}
