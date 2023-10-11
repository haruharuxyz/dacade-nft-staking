// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DacadePunks is ERC721AQueryable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Strings for uint256;

    string public baseURI;
    string public constant baseExtension = ".json";

    uint256 public cost;
    uint256 public immutable maxSupply;
    uint256 public maxMintAmountPerTx;
    bool public paused;

    event Minted(address indexed to, uint256 amount);
    event CostChanged(uint256 newCost);
    event MintLimitChanged(uint256 newLimit);
    event BaseURIChanged(string newBaseURI);
    event ContractPaused(bool isPaused);
    event Withdrawn(address owner, uint256 amount);

    constructor(
        uint256 _maxSupply,
        uint256 _cost,
        uint256 _maxMintAmountPerTx
    ) ERC721A("Dacade Punks Collectible", "DPC") {
        cost = _cost;
        maxMintAmountPerTx = _maxMintAmountPerTx;
        maxSupply = _maxSupply;
        paused = false;
    }

    function mint(uint256 _mintAmount) external payable nonReentrant {
        require(!paused, "Contract is paused");
        require(_mintAmount > 0, "Invalid mint amount");
        require(_mintAmount <= maxMintAmountPerTx, "Max mint amount exceeded");
        uint256 supply = totalSupply();
        require(supply.add(_mintAmount) <= maxSupply, "NFT supply limit exceeded");

        uint256 requiredAmount = cost.mul(_mintAmount);
        require(msg.value >= requiredAmount, "Insufficient funds");

        for (uint256 i = 0; i < _mintAmount; i++) {
            uint256 tokenId = supply.add(1);
            _safeMint(msg.sender, tokenId);
        }

        emit Minted(msg.sender, _mintAmount);
    }

    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
        emit CostChanged(_newCost);
    }

    function setMaxMintAmountPerTx(uint256 _newLimit) external onlyOwner {
        maxMintAmountPerTx = _newLimit;
        emit MintLimitChanged(_newLimit);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
        emit BaseURIChanged(_newBaseURI);
    }

    function pause(bool _state) external onlyOwner {
        paused = _state;
        emit ContractPaused(_state);
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: contractBalance}("");
        require(success, "Withdrawal failed");
        emit Withdrawn(owner(), contractBalance);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
                : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
