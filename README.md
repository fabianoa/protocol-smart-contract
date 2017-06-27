
## Executando o contrato `ProtocoloManager` na console do Ethereum

O smart-contract ProtocoloManager é um contrato desenvolvido na plataforma Ethereum, em linguagem solidity que compõe uma Dapp (Decentralized Application) de Gestão de Protocolo. O mesmo possui função de controlador, implementando o  padrão factory de protocolos. Através de suas funções é possível criar contratos do tipo Protocolo, obter informações sobre contratos criados, executar operações de envio e recebimento, entre outras.


Para executar um contrato ProtocoloManager no ethereum via console,  execute os seguintes passos:

1 . Abra o console do ethereum, se conectando a rede blockchain da DTP.

```
> geth attach http://n461d0116e00362-ext.nuvemdtp:8080 

```
2 . Agora  utilize o comando abaixo para inicalizarmos nossa variavel de contrato.

```
var contract = eth.contract(abi).at(contractaddress)
```
Para isto é necessário substituirmos os parâmetros **abi**,   que pode ser obtido no arquivo [ProtocoloManager.json](https://www-git.prevnet/governanca-tecnologia/blockchain/blob/master/dtp-smart-contract-blokchain-protocolo/build/contracts/ProtocoloManager.json) gerado pelo truffle e o **contractaddress** que pode ser obtido no [arquivo de registro de deploys](https://www-git.prevnet/governanca-tecnologia/blockchain/blob/master/dtp-smart-contract-blokchain-protocolo/migrations/ultimosdeploys.txt). Segue exemplo: 

```
var protocoloManagerContract = web3.eth.contract([
    {
      "constant": false,
      "inputs": [
        {
          "name": "_numero",
          "type": "address"
        }
      ],
      "name": "obterSituacaoProtocolo",
      "outputs": [
        {
          "name": "",
          "type": "int8"
        }
      ],
      "payable": false,
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "_tipoProtocolo",
          "type": "uint256"
        },
        {
          "name": "_assunto",
          "type": "string"
        },
        {
          "name": "_descricao",
          "type": "string"
        }
      ],
      "name": "criar",
      "outputs": [
        {
          "name": "rprotocolo",
          "type": "address"
        }
      ],
    ...
    ...
    ...).at('0xc13c444a67f01f16ce1f1dc41b5984a44ce112de');

```

3 . Para chamarmos as funções que  alteram o estado do contrato ou que gerem novos contratos, devemos executar a respectiva função, referênciando-a na varíavel instânciada anteriormente, passando os parâmetros exigidos  e fornecendo algumas informações sobre como o "custo de execução" será pago.
Estas informações de custos são: a conta que irá "pagar" o custo (from), a quantidade de  **gas** oferecido  e o **grasPrice**. Antes porém de executar a referida função, devemos desbloquear a conta utilizada na transação. 
Abaixo temos um exemplo de chamada da função **criar** que tem o  objetivo de criar um novo contrato do tipo Protocolo a ser gerenciado (controlado) pelo contrato do tipo **ProtocoloManager**.

```
> personal.unlockAccount(eth.accounts[0])
Unlock account 0x607d731436d8f6524fe30d59b563bdcfe161ec81
Passphrase: <digite a senha> 
true
> protocoloManagerContract.criar(1,'Meu primeiro protocolo','Este é um teste de criação de um protocolo no blockchain',{from:web3.eth.accounts[0],gas: 4712388,gasPrice:10000})

"0xcf0b65522a2aa037fc539eea2b7857420bc4216506033899295c36017d8f60e6"  //número da transação gerada

```
Agurade a transação ser concluída. Você pode acompanha-la através do comando : **eth.pendingTransactions**


4 . Para verificarmos o endereço do contrato criado, execute o comando:

```
> protocoloManagerContract.obter.call(0)
"0xdbc6ba4060c305e178a69e13d450cc5a3092b194"
```
Observe que desta vez  para a função chamada, não foi necessário "pagar" nenhum valor. Isto aconteceu porque tal chamada não altera o estado do contrato, apenas ler seus atributos.

5 .Verificando a situação do contrato criado:

```
> protocoloManagerContract.obterSituacaoProtocolo.call(protocoloManagerContract.obter.call(0))       //ou
> protocoloManagerContract.obterSituacaoProtocolo.call('0xdbc6ba4060c305e178a69e13d450cc5a3092b194')
1  // Código para "Aberto"
```

6 . Agora vamos executar função que realiza movimentação (envio) do procolo criado. Como esta função altera o estado do contrato, a mesma precisa de "pagamento".

```
> eth.accounts
["0x607d731436d8f6524fe30d59b563bdcfe161ec81", "0x9bd9b2b27f69dbae4f8df16d9c660f99a4cfd7df"] //vamos utilizar a segunda conta para destinatário
> personal.unlockAccount(eth.accounts[0])
Unlock account 0x607d731436d8f6524fe30d59b563bdcfe161ec81
Passphrase: <digite a senha> 
true 
> protocoloManagerContract.enviarProtocolo('0xdbc6ba4060c305e178a69e13d450cc5a3092b194','0x9bd9b2b27f69dbae4f8df16d9c660f99a4cfd7df','Conforme solicitado',{from:web3.eth.accounts[0],gas: 4712388,gasPrice:10000})

"0xfdeeb975e688de5016166311f48558e3348c61a3245bac4893c3d2926f067fb8" //numero da transação gerada


```
Após a transação se concluída, verifique a nova situação do contrato com o comando abaixo:

```
protocoloManagerContract.obterSituacaoProtocolo.call(protocoloManagerContract.obter.call(0))

2       // Código para "Aguardando recebimento"
```

7 . Por fim iremos executar o recebimento do protocolo criado.

```
> personal.unlockAccount(eth.accounts[1]) // Desbloqueando senha do usuário destinatário

> protocoloManagerContract.receberProtocolo('0xa328835965a7cd617ccb09d4fbb8d16698e789b4',{from:web3.eth.accounts[1],gas: 4712388,gasPrice:10000})

"0x2002e1419695c32b0e02adf60a4778dce563784ec6380eb10970e3da7ffdcb17"

```
Observe que a conta utilizada nesta transação é a eth.accounts[1] e não a eth.accounts[0]. Isto porque o contrato Protocolo faz uma verificação de segurança do usuário, testando se o mesmo é igual ao do destinatário.


Após a transação se concluída, verifique a nova situação do contrato com o comando abaixo:

```
> protocoloManagerContract.obterSituacaoProtocolo.call(protocoloManagerContract.obter.call(0))

3       // Código para "Recebido"
```

# truffle-init-webpack
Example webpack project with Truffle. Includes contracts, migrations, tests, user interface and webpack build pipeline.

## Usage

To initialize a project with this exapmple, run `truffle init webpack` inside an empty directory.

## Building and the frontend

1. First run `truffle compile`, then run `truffle migrate` to deploy the contracts onto your network of choice (default "development").
1. Then run `npm run dev` to build the app and serve it on http://localhost:8080

## Possible upgrades

* Use the webpack hotloader to sense when contracts or javascript have been recompiled and rebuild the application. Contributions welcome!

## Common Errors

* **Error: Can't resolve '../build/contracts/MetaCoin.json'**

This means you haven't compiled or migrated your contracts yet. Run `truffle compile` and `truffle migrate` first.

Full error:

```
ERROR in ./app/main.js
Module not found: Error: Can't resolve '../build/contracts/MetaCoin.json' in '/Users/tim/Documents/workspace/Consensys/test3/app'
 @ ./app/main.js 11:16-59
```

