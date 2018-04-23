require! {
    \superagent : { get, post }
    \./ProdPrivateSale.abi.json : presale-abi
    \./ProdToken.abi.json : token-abi
}
get-projects-builder = (url) -> (cb)->
    err, data <- get "#{url}/api/projects" .timeout(deadline: 3000).end
    return cb err if err?
    cb null, JSON.parse(data.text)
get-project-details-builder = (url)-> (token, cb)->
    err, data <- get "#{url}/api/project/#{token}" .timeout(deadline: 3000).end
    return cb err if err?
    cb null, JSON.parse(data.text)
add-project-builder = (url, model, cb)-->
    err, data <- post "#{url}/api/add" , model .timeout(deadline: 3000).end
    return cb data?text ? err if err?
    cb null, JSON.parse(data.text)
tokensale-contract = (web3, address)-->
    Contract = web3.eth.contract presale-abi
    Contract.at address
token-contract = (web3, address)-->
    Contract = web3.eth.contract token-abi
    Contract.at address
factory = (web3, url)->
    tokensale-contract-at = tokensale-contract web3
    token-contract-at = token-contract web3
    get-projects = get-projects-builder url
    get-project-details = get-project-details-builder url
    add-project = add-project-builder url
    { add-project, get-projects, get-project-details, tokensale-contract-at, token-contract-at }
module.exports = factory