import './App.css';
import { useState } from "react"
import { connect } from "get-starknet"
import { Contract } from "starknet"
import { toBN, toHex } from "starknet/dist/utils/number"
import { bnToUint256, uint256ToBN } from "starknet/dist/utils/uint256"
import contractAbi from "./contract_abi.json"

const contractAddress = "0x025f46d3136f7cca47177800cc0fe29320c8f06ed2bf2ea226c91d2626bf7ec4"


function App() {
  const [provider, setProvider] = useState('')
  const [address, setAddress] = useState('')
  const [receiverAddress, setReceiverAddress] = useState('')
  const [retrievedCount, setRetrievedCount] = useState('')
  const [retrievedOwner, setRetrievedOwner] = useState('')
  const [retrievedOriginalOwner, setRetrievedOriginalOwner] = useState('')
  const [isConnected, setIsConnected] = useState(false)
  const [tokenId, setTokenId] = useState('')

  const connectWallet = async() => {
    try{
      // connect the wallet
      const starknet = await connect()
      await starknet?.enable({ starknetVersion: "v4" })
      // set up the provider
      setProvider(starknet.account)
      // set wallet address
     setAddress(starknet.selectedAddress)
      // set connection flag
      setIsConnected(true)
      
    }
    catch(error){
      alert(error.message)
    }
  }

  const mint = async() => {
    try{
      // create a contract object based on the provider, address and abi
      const contract = new Contract(contractAbi, contractAddress, provider)

      // call the mint function
      await contract.mint(receiverAddress)
      
    }
    catch(error){
      alert(error.message)
    }
  }

  const getCounter = async() => {
    try{
      // create a contract object based on the provider, address and abi
      const contract = new Contract(contractAbi, contractAddress, provider)
      // call the function
      const result = await contract.getCounter()
      // decode the result
      const _retrievedCount = uint256ToBN(result.id).toString()
      // display the result
      setRetrievedCount(_retrievedCount)
    }
    catch(error){
      alert(error.message)
    }
  }

  const getOwner = async() => {
    try{
      // create a contract object based on the provider, address and abi
      const contract = new Contract(contractAbi, contractAddress, provider)
      // call the function
      const result = await contract.ownerOf(bnToUint256(tokenId))
      // decode the result
      const _decodedOwner = toHex(toBN(result.owner))
      // display the result
      setRetrievedOwner(_decodedOwner)
    }
    catch(error){
      alert(error.message)
    }
  }

  const getOriginalOwner = async() => {
    try{
      // create a contract object based on the provider, address and abi
      const contract = new Contract(contractAbi, contractAddress, provider)
      // call the function
      const result = await contract.getOriginalOwner(bnToUint256(tokenId))
      // decode the result
      const _decodedOriginalOwner = toHex(toBN(result.owner))
      // display the result
      setRetrievedOriginalOwner(_decodedOriginalOwner)
    }
    catch(error){
      alert(error.message)
    }
  }

  const getOwners = async() => {
    try{
      getOwner()
      getOriginalOwner()
    }
    catch(error){
      alert(error.message)
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <main className="main">
          <h1 className="title">
            Minimal Starknet JS DEMO
          </h1>
          {
            isConnected ?
            <button className="connect">{address.slice(0, 5)}...{address.slice(60)}</button> :
            <button className="connect" onClick={() => connectWallet()}>Connect wallet</button>
          }

          <p className="description">
            Using Starknet JS with a simple <a href="https://github.com/ftupas/encode-cairo-bootcamp/blob/main/homework_9/contracts/erc721/erc721.cairo"> contract</a>
          </p>

          <div className="grid">
            <div href="#" className="card">
              <h2>Use Alpha-goerli testnet! &rarr;</h2>


              <div className="cardForm">

                <input type="submit" className="button" value="Mint" onClick={() => mint()} />
                <input type="text" className="input" placeholder="Address" name="mintAddress" id="mintAddress" onChange={(e) => setReceiverAddress(e.target.value)}></input>

              </div>

              <hr />

              <div className="cardForm">
               
                <input type="submit" className="button" value="Get Counter" onClick={() => getCounter()} />
                <p>Tokens Minted: {retrievedCount}</p>
              </div>
              <hr />
              <div className="cardForm">
                <input type="submit" className="button" value="Get OG Owner" onClick={() => getOwners()} />
                <input type="text" className="input" placeholder="Token ID" name="tokenId" id="tokenId" onChange={(e) => setTokenId(e.target.value)}></input>
                <p>Owner: {retrievedOwner}</p> 
                <p>OG Owner: {retrievedOriginalOwner}</p> 
              </div>
              
            </div>
          </div>
        </main>
      </header>
    </div>
  );
}

export default App;
