import React, { useState, useEffect } from "react";
import NavBar from '../components/NavBar';
import { useNavigate } from "react-router-dom";
import { useSelector } from "react-redux"
import { ethers } from "ethers";
import { Form } from "react-bootstrap";
import { CircularProgress } from "@mui/material";

import nftContract from "../artifacts/DacadePunks.sol/DacadePunks.json";
import { nftContractAddress, ownerAddress, networkDeployedTo } from "../utils/contracts-config";
import networksMap from "../utils/networksMap.json";

const Dashboard = () => {
    let navigate = useNavigate();
    const data = useSelector((state) => state.blockchain.value)
    // State for application information
    const [appInfo, setAppInfo] = useState({
        nftContractBalance: 0,
        nftContractPaused: 1,
        maxMintAmountPerTx: 5,
        mintCost: 0
    })

    // State for loading indicator
    const [loading, setLoading] = useState(false)

    // Function to fetch application information from the Ethereum network
    // Function to fetch application information from the Ethereum network
    async function getAppInfo() {
        if (data.network === networksMap[networkDeployedTo] && data.account !== "") {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
                const nft_contract = new ethers.Contract(nftContractAddress, nftContract.abi, provider);

                if (ownerAddress !== data.account) {
                    navigate("/");
                    return;
                }

                const balance = await provider.getBalance(nftContractAddress);
                const ispaused = await nft_contract.callStatic.paused();
                const _fee = await nft_contract.callStatic.cost();
                const _maxMintAmount = await nft_contract.callStatic.maxMintAmountPerTx();

                // Update the appInfo state with fetched data
                setAppInfo({
                    nftContractBalance: Number(ethers.utils.formatUnits(balance, "ether")),
                    nftContractPaused: Number(ispaused),
                    maxMintAmountPerTx: _maxMintAmount,
                    mintCost: Number(ethers.utils.formatUnits(_fee, "ether")),
                });
            } catch (error) {
                // Handle errors and navigate back to the homepage
                navigate("/");
                console.error(error);
            }
        } else {
            // Handle cases where the network is not compatible or the user is not authenticated
            navigate("/");
        }
    }

    // Function to handle Ethereum transactions and update the loading state
    async function handleTransaction(action, transactionFunction) {
        if (data.network !== networksMap[networkDeployedTo]) {
            return;
        }
    
        try {
            setLoading(true);
            const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
            const signer = provider.getSigner();
            const nft_contract = new ethers.Contract(nftContractAddress, nftContract.abi, signer);
    
            const transaction = await transactionFunction(nft_contract);
            await transaction.wait();
            setLoading(false);
            window.location.reload();
        } catch (error) {
            setLoading(false);
            window.alert("An error has occurred");
            console.error(error);
        }
    }

    // Function to change the mint cost for NFTs
    async function changeMintCost() {
        await handleTransaction("Change Mint Cost", async (contract) => {
            return contract.setCost(ethers.utils.parseEther(String(appInfo.mintCost), "ether"));
        });
    }
    
     // Function to change the maximum mint amount per transaction
    async function changeMintAmount() {
        await handleTransaction("Change Mint Amount", async (contract) => {
            return contract.setMaxMintAmountPerTx(appInfo.maxMintAmountPerTx);
        });
    }
    
    // Function to withdraw funds from the contract
    async function withdraw() {
        await handleTransaction("Withdraw Funds", async (contract) => {
            return contract.withdraw();
        });
    }

    // Function to change the contract state (pause/unpause)    
    async function changeContractState() {
        await handleTransaction("Change Contract State", async (contract) => {
            if (appInfo.nftContractPaused === 1) {
                return contract.pause(2);
            } else {
                return contract.pause(1);
            }
        });
    }

    // Effect hook to fetch application information on changes
    useEffect(() => {
        if (window.ethereum !== undefined) {
            getAppInfo()
        }
    }, [data.account])


    return (
        <>
            <NavBar />
            <br />
            <div className="dashboard-section">
                <h1 className="text-center" style={{ paddingTop: "30px" }}>
                    Owner Dashboard
                </h1>
                <div className="dashboard-container">
                    <div className="dashboard-content">
                        <div className='dashboard-row' >
                            <div className='dashboard-left'>
                                <label>Current contract balance : {appInfo.nftContractBalance} CELO</label>
                            </div>
                            <div className='dashboard-button-up'>
                                <button className='btn btn-info' onClick={withdraw}>
                                    {loading ? <CircularProgress color="inherit" size={18} /> : "withdraw"}
                                </button>
                            </div>
                        </div>
                        <br />
                        <div className='dashboard-row'>
                            <div className='dashboard-left'>
                                <label>Max NFT minted per transaction : </label>
                                <Form.Control type="Number"
                                    value={appInfo.maxMintAmountPerTx}
                                    onChange={(e) => setAppInfo({ ...appInfo, maxMintAmountPerTx: e.target.value })}
                                />
                            </div>
                            <div className='dashboard-button' >
                                <button className='btn btn-info' onClick={changeMintAmount}>
                                    {loading ? <CircularProgress color="inherit" size={18} /> : "Change"}
                                </button>
                            </div>
                        </div>
                        <br />
                        <div className='dashboard-row'>
                            <div className='dashboard-left'>
                                <label>NFT mint cost (CELO) : </label>
                                <Form.Control type="Number"
                                    value={appInfo.mintCost}
                                    onChange={(e) => setAppInfo({ ...appInfo, mintCost: e.target.value })}
                                />
                            </div>
                            <div className='dashboard-button' >
                                <button className='btn btn-info' onClick={changeMintCost}>
                                    {loading ? <CircularProgress color="inherit" size={18} /> : "Change"}
                                </button>
                            </div>
                        </div>
                        <br />
                        <br />
                        <div className='dashboard-row'>
                            <div className='dashboard-left'>
                                <label>
                                    {appInfo.nftContractPaused == 1 ? (
                                        "Nft Contract is paused"
                                    ) : (
                                        "Nft Contract is active"
                                    )}
                                </label>
                            </div>
                            <div className='dashboard-button-up'>
                                <button className='btn btn-info' onClick={changeContractState}>
                                    {appInfo.nftContractPaused == 1 ? (
                                        loading ? <CircularProgress color="inherit" size={18} /> : "Activate"
                                    ) : (
                                        loading ? <CircularProgress color="inherit" size={18} /> : "Pause"
                                    )}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
};

export default Dashboard;