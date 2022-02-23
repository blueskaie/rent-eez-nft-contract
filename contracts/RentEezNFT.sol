// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract RentEezNFT is ERC721("RentEezNFT", "REN"), ERC721Enumerable, Ownable, Pausable {
    using SafeMath for uint256;
    using Strings for uint256;

    string[7] private _metaDataURI = [
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/1',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/5',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/6',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/7',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/8',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/9',
        'ipfs://Qmf9DyWJFos5UCrmUMvwTp8PLKkbeUJ8Gcw9tiDU8dqFaT/10'
    ];
    
    uint256[] private _metaDataIndex = [0, 1, 2, 3, 4, 5, 6];

    uint256 public MAX_NFT = 700;
    uint256 public PerMintCount = 7;
    uint256 public NFTPrice = 0.25 * (10**18);  // 0.25 BNB
    uint256 public randNonce = 0;
    mapping (uint256 => uint256) private _tokenURIs;
    mapping (uint256 => uint256) private _mintCount;

    constructor() {}

    /*
     * Function to withdraw collected amount during minting
    */
    function withdraw(address _to) public onlyOwner {
        uint balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    /*
     * Function to update the nft price
    */
    function editPrice(uint256 _newPrice) public onlyOwner {
        NFTPrice = _newPrice;
    }

    /*
     * Function to mint new NFTs
     * It is payable. Amount is calculated as per (NFTPrice*_numOfTokens)
    */
    function mintNFT(uint256 _numOfTokens) public payable whenNotPaused {
        require( _numOfTokens <= PerMintCount, "It can only mint 7 images at a time");
        require(totalSupply().add(_numOfTokens) <= MAX_NFT, "Purchase would exceed max supply of NFTs");
        require(NFTPrice.mul(_numOfTokens) == msg.value, "Ether value sent is not correct");

        for(uint i=0; i < _numOfTokens; i++) {
            uint tokenId = totalSupply();
            uint rand = _generateRandomNumber(_metaDataIndex.length, randNonce++);
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, _metaDataIndex[rand]);
            _mintCount[_metaDataIndex[rand]] = _mintCount[_metaDataIndex[rand]] + 1;
            if(_mintCount[_metaDataIndex[rand]] >= 100) {
                remove(rand);
            }
        }
    }

    function getMintCount(uint _index) public view returns(uint) {
        return _mintCount[_index];
    }

    /*
     * Function to get token URI of given token ID
     * URI will be blank untill totalSupply reaches MAX_NFT
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _metaDataURI[_tokenURIs[tokenId]];
    }

    /*
     * Function to set Base and Blind URI 
    */
    function setURIs(string[7] memory _URIs) external onlyOwner {
        require(_URIs.length == 7, "7 URI required");
        _metaDataURI = _URIs;
    }

    /*
     * Function to pause 
    */
    function pause() external onlyOwner {
        _pause();
    }

    /*
     * Function to unpause 
    */
    function unpause() external onlyOwner {
        _unpause();
    }

    // Standard functions to be overridden 
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _generateRandomNumber(uint _modulus, uint nonce) internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender,  nonce)));
        return rand % _modulus;
    }

    function _setTokenURI(uint256 tokenId, uint256  RandomNo) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = RandomNo;
    }

    function remove(uint index) internal {
        _metaDataIndex[index] = _metaDataIndex[_metaDataIndex.length - 1];
        _metaDataIndex.pop();
    }
}