require! {
    \superagent : { get, post }
    \./ProdPrivateSale.abi.json : presale-abi
    \./ProdToken.abi.json : token-abi
}
new-standard = (web3, abi, address)->
    contract = new web3.eth.Contract abi, address
    contract.abi = abi
    contract
create-contract = (web3, abi, address)->
    | typeof! web3.eth.contract is \Function => web3.eth.contract abi .at address
    | _ => new-standard web3, abi, address
tokensale-contract = (web3, address)-->
    create-contract web3, presale-abi, address
token-contract = (web3, address)-->
    create-contract web3, token-abi, address
parse-json = (text, cb)->
    try
        return cb null, JSON.parse text
    catch
        return cb "Cannot parse json"
deadline = 3000
extract-signature = (signature)->
    sig = signature.slice 2
    r = \0x + sig.slice 0, 64
    s = \0x + sig.slice 64, 128
    v = \0x + sig.slice 128, 130
    { v, r, s }
get-projects-builder = (url) -> (cb)->
    err, data <- get "#{url}/api/projects" .timeout({ deadline }).end
    return cb err if err?
    err, model <- parse-json data.text
    return cb err if err?
    cb null, model
get-data-builder = (contract, method)->
    | contract.methods? => -> contract.methods[method].apply null, Array.from(arguments) .encodeABI!
    | _ => contract[method].get-data
to-wei-builder = (web3)->
    web3.to-wei ? web3.utils.to-wei
create-authorised-tx = ({ type, url, web3, token, amount-ethers, method, contract-address }, cb)->
    address = web3.eth.default-account
    return cb "web3.eth.defaultAccount is not defined" if not web3.eth.default-account?
    contract = tokensale-contract web3, contract-address
    err, data <- get "#{url}/api/perm/#{type}/#{token}/#{address}" .timeout({ deadline }).end
    return cb data.text if err?
    access-key = JSON.parse data.text
    { signature, length } = access-key
    { v, r, s } = extract-signature signature
    get-data = get-data-builder contract, method
    to-wei = to-wei-builder web3
    transaction =
        to: contract-address
        gas: 500000
        value: to-wei("#{amount-ethers}", \ether).to-string!
        data: get-data length, token, v, r, s
    web3.eth.send-transaction transaction, cb
claim-tokens-builder = (web3, url)-> ({token, contract-address}, cb)->
    type = \claim
    amount-ethers = 0
    method = \claimTokens
    create-authorised-tx { type, url, web3, token, method, contract-address }, cb
whitelist-buy-builder = (web3, url)-> ({amount-ethers, token, contract-address}, cb)->
    type = \contrib
    method = \whitelistBuy
    create-authorised-tx { type, url, web3, token, method, contract-address }, cb
get-project-details-builder = (url)-> (token, cb)->
    err, data <- get "#{url}/api/project/#{token}" .timeout({ deadline }).end
    return cb err if err?
    err, model <- parse-json data.text
    return cb err if err?
    cb null, model
add-project-builder = (url, model, cb)-->
    err, data <- post "#{url}/api/add" , model .timeout({ deadline }).end
    return cb data?text ? err if err?
    err, model <- parse-json data.text
    return cb err if err?
    cb null, model
factory = (web3, url)->
    tokensale-contract-at = tokensale-contract web3
    token-contract-at = token-contract web3
    get-projects = get-projects-builder url
    get-project-details = get-project-details-builder url
    add-project = add-project-builder url
    claim-tokens = claim-tokens-builder web3, url
    whitelist-buy = whitelist-buy-builder web3, url
    { add-project, get-projects, get-project-details, tokensale-contract-at, token-contract-at, claim-tokens, whitelist-buy }
module.exports = factory