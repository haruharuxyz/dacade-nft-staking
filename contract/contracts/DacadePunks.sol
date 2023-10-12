// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @notice The DacadePunks contract is an Ethereum-based NFT (Non-Fungible Token) collectible contract.
 * It allows users to mint unique NFTs with various configurable features and control mechanisms.
 */
contract DacadePunks is ERC721AQueryable, Ownable {
    using Strings for uint256;

    /**
     * @dev The base URI for token metadata. It represents the prefix used for constructing the URI
     * of individual NFTs, including their token-specific data.
     */
    string public baseURI;

    /**
     * @dev A constant representing the file extension for token metadata, typically ".json".
     */
    string public constant baseExtension = ".json";

    /**
     * @dev The cost in ether required to mint a single NFT. Users need to send this amount with their minting transactions.
     */
    uint256 public cost;

    /**
     * @dev The maximum total supply of NFTs that can be minted by users. Once this limit is reached, no more NFTs can be minted.
     */
    uint256 public immutable maxSupply;

    /**
     * @dev The maximum number of NFTs that can be minted in a single transaction. This parameter helps control the number of NFTs that can be minted at once.
     */
    uint256 public maxMintAmountPerTx;

    /**
     * @dev Represents the current contract state: 1 for paused (no minting allowed), 2 for active (minting allowed).
     */
    uint256 public paused = 1;

    /**
     * @dev Custom error types for handling exceptional conditions that may arise during contract interactions.
     * These errors are used to provide descriptive feedback to users when errors occur.
     */
    error DacadePunks__ContractIsPaused();
    error DacadePunks__NftSupplyLimitExceeded();
    error DacadePunks__InvalidMintAmount();
    error DacadePunks__MaxMintAmountExceeded();
    error DacadePunks__InsufficientFunds();
    error DacadePunks__QueryForNonExistentToken();

    /**
    * @notice Constructor to initialize the DacadePunks NFT Collectible Contract.
    * @dev This contract allows users to mint unique collectible NFTs with various features and control mechanisms.
    * @param _maxSupply The maximum total supply of NFTs that can be minted by users.
    * @param _cost The cost, in ether, required to mint a single NFT.
    * @param _maxMintAmountPerTx The maximum number of NFTs that can be minted in a single transaction.
    * @dev The contract owner can configure the following parameters:
    * @param _maxSupply The maximum total supply of NFTs that can ever be minted. Once this limit is reached, no more NFTs can be minted.
    * @param _cost The cost, in ether, for users to mint a single NFT. Users must send this amount with their minting transactions.
    * @param _maxMintAmountPerTx The maximum number of NFTs that can be minted in a single transaction. This helps control the number of NFTs that can be minted at once.
    */
    constructor(
        uint256 _maxSupply,
        uint256 _cost,
        uint256 _maxMintAmountPerTx
    ) ERC721A("Dacade Punks Collectible", "DPC") {
        cost = _cost;
        maxMintAmountPerTx = _maxMintAmountPerTx;
        maxSupply = _maxSupply;
    }

    /**
     * @notice Mint a specified number of NFTs. Users can mint NFTs by sending the appropriate amount of ether.
     * @dev This function enforces various checks to ensure valid minting conditions, such as contract pause status, valid mint amounts, and sufficient funds.
     * @param _mintAmount The number of NFTs to mint.
     * @dev Requirements:
     * - The contract must not be paused (state 2) to allow minting.
     * - The requested mint amount must be greater than 0.
     * - The requested mint amount must not exceed the maximum mint amount allowed per transaction.
     * - The total supply of NFTs after minting must not exceed the maximum total supply.
     * - If the sender is not the owner of the contract, they must send enough ether to cover the minting cost.
     */
    function mint(uint256 _mintAmount) external payable {
        // Check if the contract is paused; if so, disallow minting.
        if (paused == 1) revert DacadePunks__ContractIsPaused();
        
        // Check for a valid mint amount.
        if (_mintAmount == 0) revert DacadePunks__InvalidMintAmount();
        
        // Check if the requested mint amount exceeds the maximum allowed per transaction.
        if (_mintAmount > maxMintAmountPerTx) revert DacadePunks__MaxMintAmountExceeded();
        
        // Calculate the current total supply after minting.
        uint256 supply = totalSupply();
        
        // Ensure that minting won't exceed the maximum total supply.
        if (supply + _mintAmount > maxSupply) revert DacadePunks__NftSupplyLimitExceeded();
        
        // If the sender is not the owner, check if they sent enough ether to cover the minting cost.
        if (msg.sender != owner()) {
            if (msg.value < cost * _mintAmount) revert DacadePunks__InsufficientFunds();
        }
        
        // Mint the requested NFTs for the sender.
        _safeMint(msg.sender, _mintAmount);
    }

    
    /**
     * @notice Set the cost in ether to mint a single NFT. Only the contract owner can update this value.
     * @param _newCost The new cost value in ether.
     */
    function setCost(uint256 _newCost) external payable onlyOwner {
        cost = _newCost;
    }

    /**
     * @notice Set the maximum number of NFTs that can be minted in a single transaction.
     * @dev This function can be called only by the contract owner.
     * @param _newmaxMintAmount The new maximum mint amount.
     */
    function setMaxMintAmountPerTx(uint256 _newmaxMintAmount)
        external
        payable
        onlyOwner
    {
        maxMintAmountPerTx = _newmaxMintAmount;
    }

    /**
     * @notice Set the base URI for token metadata. The contract owner can define a new base URI.
     * @dev The base URI is used to construct the URI for individual NFTs by appending the token-specific data to it.
     * @param _newBaseURI The new base URI.
     */
    function setBaseURI(string memory _newBaseURI) external payable onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     * @notice Pause or unpause the contract (1 for paused, 2 for active). Only the contract owner can control the contract's state.
     * @param _state New contract state (1 for paused, 2 for active).
     * @dev The owner can pause or unpause the contract to control the minting process and other contract operations.
     */
    function pause(uint256 _state) external payable onlyOwner {
        paused = _state;
    }

    /**
     * @notice Withdraw any ether balance from the contract. Only the contract owner can withdraw funds.
     * @dev The owner can use this function to withdraw any accumulated ether balance from the contract.
    */
    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    /**
     * @notice Get the token URI for a specific token ID.
     * @param tokenId Token ID to query.
     * @return Token's URI.
     * @dev This function returns the URI of the metadata associated with a specific NFT, which includes its token-specific data.
     * @dev If the queried token does not exist, it will revert with the appropriate error.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert DacadePunks__QueryForNonExistentToken();

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    /**
     * @dev Get the base URI for token metadata.
     * @return Base URI.
     * @dev This internal function is used to retrieve the base URI for token metadata, which forms the prefix for constructing token-specific URIs.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
