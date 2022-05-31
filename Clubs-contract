// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Clubs is  ERC721, Ownable {
     string private _baseTokenURI;
     using Counters for Counters.Counter;
      Counters.Counter private _tokenIdTracker;
     mapping(uint256 => string) private urlMap;
     constructor(string memory name_, string memory symbol_,string memory baseTokenURI) ERC721(name_, symbol_){
         _baseTokenURI = baseTokenURI;

     }
     function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
     function mint(address to,string memory url) public virtual returns (uint256){
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 tokenId = _tokenIdTracker.current();
        _mint(to, tokenId);
        urlMap[tokenId] = url;
        _tokenIdTracker.increment();
        return tokenId;
    }
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        string memory url = urlMap[tokenId];
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, url)) : "";
    }
    
}

