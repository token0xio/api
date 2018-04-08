### ICO suite API

This nodejs module for ICOsuite integration

Status: Implemented MVP

[Website](http://icosuite.network) | [Discuss](https://t.me/icosuite)

#### Use API

```
npm i icosuite
```

```Javascript

//API is UNDER CONSTRUCTION

var web3 = if window ? window.web3 : require('web3');

var nodeURI = "https://icosuite.network"

var icosuite = require('icosuite')(window.web3, nodeURI);

var showResult = function(err, result) {
    console.log(err, result);
}

// Add New Project

icosuite.addProject(project, showResult);


// Get list of public projects

icosuite.getProjects(showResult);


// Get project details

icosuite.getProjectDetails('BTC', showResult);


// Get tokensale contract

icosuite.tokensaleContractAt('0x....') //use contract methods


// Get token contract

icosuite.tokenContractAt('0x....') //use contract methods

```


-----------------

icosuite.network