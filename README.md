### Token0x API

This nodejs module for Token0x integration

Status: Implemented MVP

[Website](http://token0x.io) | [Discuss](https://t.me/token0x)

#### Use API

```
npm i token0x --save
```

```Javascript


var web3 = if window ? window.web3 : require('web3');

var nodeURI = "https://token0x.io"

var token0x = require('token0x')(window.web3, nodeURI);

var showResult = function(err, result) {
    console.log(err, result);
}

// Add New Project

token0x.addProject(project, showResult);


// Get list of public projects

token0x.getProjects(showResult);


// Get project details

token0x.getProjectDetails('BTC', showResult);


// Get tokensale contract

token0x.tokensaleContractAt('0x....') //use contract methods


// Get token contract

token0x.tokenContractAt('0x....') //use contract methods

```


-----------------

token0x.io