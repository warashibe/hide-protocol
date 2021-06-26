//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract NFT is Ownable, ERC721PresetMinterPauserAutoId {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  string private _baseTokenURI;
  constructor(string memory _name, string memory _sym, string memory baseTokenURI) ERC721PresetMinterPauserAutoId(_name, _sym, baseTokenURI) {}
  
  function setBaseURI(string memory baseTokenURI) public onlyOwner {
    _baseTokenURI = baseTokenURI;
  }
  
  function addMinter(address _minter) public {
    grantRole(MINTER_ROLE, _minter);
  }
  
  function removeAgent(address _minter) public {
    revokeRole(MINTER_ROLE, _minter);
  }
  
  function mint (address _to, string memory _url) public onlyRole(MINTER_ROLE) returns(uint id) {
    _tokenIds.increment();
    id = _tokenIds.current();
    _mint(_to, id);
    _setTokenURI(id, _url);
  }
  
  using Strings for uint256;

  // Optional mapping for token URIs
  mapping (uint256 => string) private _tokenURIs;

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

    string memory _tokenURI = _tokenURIs[tokenId];
    string memory base = _baseURI();

    // If there is no base URI, return the token URI.
    if (bytes(base).length == 0) {
      return _tokenURI;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(_tokenURI).length > 0) {
      return string(abi.encodePacked(base, _tokenURI));
    }

    return super.tokenURI(tokenId);
  }

  /**
   * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  /**
   * @dev Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual override {
    super._burn(tokenId);

    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }  
}
