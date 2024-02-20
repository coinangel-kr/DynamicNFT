//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract Realty is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;

    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmYHvgehY9b8LLSAxg7g8crVrVuvkgCuV3Ujm2tTRZpvLS",
        "https://ipfs.io/ipfs/QmebFrQLvszRvtCt2u6EBSmckm7a3r2zXrPsjmjinpcVy2",
        "https://ipfs.io/ipfs/QmNoQjPJK6X3UCybTHeV2atrRkJLwXPz7U21WwCX1RPGws",
        "https://ipfs.io/ipfs/QmeVnSPcvh275CYJW8khdzJsme6KaBXPdo7wbbqE3cwoeP"
    ];

    uint public immutable interval;
    uint public lastTimeStamp;

    constructor(uint updateInerval) ERC721("Realty with person", "REAL") {
        interval = updateInerval;
        lastTimeStamp = block.timestamp;
        safemint(msg.sender);
    }

    function safemint(address to) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function comparesStrings(string memory a, string memory b) public pure returns(bool) {
        return(keccak256((abi.encodePacked(a))) == keccak256(abi.encodePacked((b))));
    }

    function RealtyIndex(uint256 _tokenId) public view returns(uint256) {
        string memory _uri = tokenURI(_tokenId);
        if (comparesStrings(_uri, IpfsUri[0])) {
            return 0;
        }
         if (comparesStrings(_uri, IpfsUri[1])) {
            return 1;
        }
         if (comparesStrings(_uri, IpfsUri[2])) {
            return 2;
        }
         if (comparesStrings(_uri, IpfsUri[3])) {
            return 3;
        }
    }

    function rotatePhoto(uint256 _tokenId) public {
        if(RealtyIndex(_tokenId) >= 3) {
            return;
        }
        else {
        uint256 newVal = RealtyIndex(_tokenId) + 1;
        string memory newUri = IpfsUri[newVal];
        _setTokenURI(_tokenId, newUri);
        }
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory ) {
        if((block.timestamp - lastTimeStamp) > interval) {
            uint256 tokenId = tokenIdCounter.current() -1;
        if (RealtyIndex(tokenId) < 3) {
            upkeepNeeded = true;
        }
        }
    }

    function performUpkeep(bytes calldata) external override {
        if((block.timestamp - lastTimeStamp) > interval) {
            uint256 tokenId = tokenIdCounter.current() -1;
        if (RealtyIndex(tokenId) < 3) {
            lastTimeStamp = block.timestamp;
            rotatePhoto(tokenId);
        }
        }
    }

    function tokenURI(uint256 tokenId) public  view override(ERC721, ERC721URIStorage) returns (string memory) {
        return  super.tokenURI(tokenId);
    }
    
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
