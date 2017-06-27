pragma solidity ^0.4.2;

// Smart contrat that manage Eletronic protocol in the Blockchain 
// Strorage list of Protocol contract Armazena lista de contratos do tipo Protocolo (Protocolo.sol)
// Intermedia a  criação, envio e recebimento de protocolos
// Realiza controle de acesso a nível de operações


/// @title Eletronic Protocol Manager.
/// @author Fabiano Alencar (332.186)

contract EletronicProtocolManager  {

    // Estrutura para armazenar principais informações do protocolo de forma apresentável
    // As informações são obtidas do contrato Protocolo criado por este contrato
    struct  ProtocolInfo {
      address  author;
      uint status; 
      address sender;
      address receiver;
      uint protocolType; //
      bytes32  subject;
      bytes32 description;
      uint creationTime;
      uint statusTime;
      uint version;
      uint managedProtocolQty;
   }

    // Variavel de controle que armazena quantidade de protocolos gerados
    uint qtManagedDoc=0;  

    //lista de controle dos protocolos gerados
    //@deprecated
    address[] documents;

    // lista de mapeamentos de endereços de Protocolos para suas respectivas informações (ProtocoloInfo)
    mapping (address => ProtocoloInfo) protocols;
    
    //evento para informar término de transação criar protocolo, retornando o endereço do mesmo
    event eventoCriarProtocolo(address _enderecoDoProtocolo);
    //evento para informar término de transação qualquer, retornando indicador de sucesso booleano (true/false)
    event confirmOperation(bool _sucesso);



    // modifier para restringir acesso para somente o destinatário do Protocolo
    modifier onlyAuthor(address _protocolAdress)
    {
        Protocol p = Protocol(_protocolAdress);
        if (msg.sender!=p.getAuthor())
            throw;
        _;
    }

    // modifier para restringir acesso para somente o destinatário do Protocolo
    modifier onlyReceiver(address _enderecoDoProtocolo)
    {
        Protocolo p = Protocolo(_enderecoDoProtocolo);
        if (msg.sender!=p.obterDestinatario())
            throw;
        _;
    }

    // modifier para restringir acesso para somente o autor ou destinatário do Protocolo
    modifier onlyAuthorAndReceiver(address _protocolAddress)
    {
        Protocol p = Protocol(_protocolAddress);
        if (msg.sender!=p.getAuthor() && msg.sender!=p.obterDestinatario())
            throw;
        _;
    }

    modifier permissaoCSomenteAutorDestinatario(address _enderecoDoProtocolo)
    {
        Protocolo p = Protocolo(_enderecoDoProtocolo);
        if (!(tx.origin==p.getAuthor() || tx.origin==p.obterDestinatario()))
            throw;
        _;
    }

    /// @notice Função transacional que cria um novo protocolo gerenciado por este contrato.
    /// @dev This does not return any excess ether sent to it
    /// @param _protocolType Código nuérico do tipo do protocolo. Ex. 1 - Documento, 2-Oficio
    /// @param _subject Assunto do protocolo criado
    /// @param _description Descrição do protocolo criado
    /// @return Por ser uma função transacional, retorna o endereço da transação. Porém esta função possui 
    /// um evento associado que retorna o endereço do contrato protocolo criado após execução da transação.
    function create( uint _protocolType, bytes32 _subject,bytes32 _description){
        
        Protocol p = new Protocol(msg.sender,_protocolType,_subject,_description);
        
        //getting the contract address
        address _protocolAddress = address(p);

        //gerando informação para apresentação e acrescentando ao mapeamento de controle protocolos
        // TODO: Melhorar a implementação
        ProtocoloInfo pi = protocolos[_enderecoDoProtocolo];
        pi.autor=msg.sender;
        pi.situacao=p.obterSituacaoAtual();
        pi.tipoProtocolo = p.obterTipoProtocolo();
        pi.assunto = _assunto;

        //Acrescentando endereço a uma lista de controle de endereços.
        //@deprecated
        protocolosAddr.push(_enderecoDoProtocolo);

        //incrementando variavel de controle
        quantidadeProtocolosGerenciados+=1;

        //chamando evento para informar endereço do protocolo gerado
        eventoCriarProtocolo(_enderecoDoProtocolo);

    }

    //Obten endereço do protocolo localizado na posição _indice da lista
    function getProtocol(uint _indice) returns (address numero) {
       numero = address(Protocol(protocolsAddr[_indice]));
    }

  

    /// @notice Função transacional que altera um contrato Protocolo existente, adicionando informações
    /// sobre novo documento anexados ao mesmo .
    /// @param _enderecoDoProtocolo Endereço do protocolo a ser alterado
    /// @param _nomeDocumento Nome amigável para o documento
    /// @param _localizacao Localização do documento. Ex. URL, código de rastreamento, etc.
    /// @param _hash Hash do documento digitalizado.
    /// @return Por ser uma função transacional, retorna o endereço da transação. Porém esta função possui 
    /// um evento associado que retorna o indicador de sucesso(true/false) da transação.
    function addDocument(address _protocolAddress, bytes32 _documentName, bytes32 _location, bytes32 _hash) 
    permissaoTSomenteAutor(_protocolAddress) {
        //retrivering protocol by the address
       Protocol p = Protocol(_protocolAddress);
      // TODO - Fazer tratamento em caso de falha
       p.addDocument(_documentName,_location,_hash);
      
       confirmOperation(true);
    } 
    
    /// @notice Função transacional que altera um contrato Protocolo existente, removendo  informações
    /// sobre  documento anteriormente anexado ao mesmo .
    /// @param _enderecoDoProtocolo Endereço do protocolo a ser alterado.
    /// @param _indiceDoDocumento Numero de 1 a 10 que representa a posição do documento na lista de documentos.
    /// @return Por ser uma função transacional, retorna o endereço da transação. Porém esta função possui 
    /// um evento associado que retorna o indicador de sucesso(true/false) da transação.
    function removeDocument(address _protocolAddress,uint _documentIndex)
    onlyAuthor(_protocolAddress) {
       //recuperando o protocolo pelo endereço
       Protocol p = Protocol(_protocolAddress);
       // TODO - Fazer tratamento em caso de falha
       p.removeDocument(_documentIndex);
       
       confirmOperation(true);
    }

    function obterDocumento(address _enderecoDoProtocolo,uint _indiceDoDocumento) permissaoCSomenteAutorDestinatario(_enderecoDoProtocolo) returns (bytes32  _nome,bytes32 _localizacao, bytes32 _hash)
    {
       //recuperando o protocolo pelo endereço
       Protocolo p = Protocolo(_enderecoDoProtocolo);
       return p.obterDocumento(_indiceDoDocumento);
       // TODO - Fazer tratamento em caso de falha
     
    }
    
    
    /// @notice Função transacional que realiza o envio de um contrato Protocolo existente para um 
    /// destinatário.
    /// @notice Esta função possui um modifier associado que restringe a operaçõ somente para o  autor ou 
    /// destintário (caso de reenvio) do Protocolo em questão.
    /// @param _enderecoDoProtocolo Endereço do protocolo a ser enviado.
    /// @param _destinatario Endereço do destinatário.
    /// @param _descricao Descrição ou informação sobre o envio.
    /// @return Por ser uma função transacional, retorna o endereço da transação. Porém esta função possui 
    /// um evento associado que retorna o indicador de sucesso(true/false) da transação.
    function sendProtocol(address _protocolAddress, address _receiver, bytes32  _description ) 
        onlyAuthorAndReceiver(_protocolAddress) {
            Protocol p = Protocol(_protocolAddress);
            p.send(_receiver,_description);
            // TODO - Fazer tratamento em caso de falha
            confirmOperation(true);
     }

    /// @notice Função transacional que realiza o recebimento de um contrato de Protocolo existente.
    /// @notice Esta função possui um modifier associado que restringe a operaçõ somente para o   
    /// destintário  do Protocolo em questão.
    /// @param _enderecoDoProtocolo Endereço do protocolo a ser enviado.
    /// @return Por ser uma função transacional, retorna o endereço da transação. Porém esta função possui 
    /// um evento associado que retorna o indicador de sucesso(true/false) da transação.
    function receiveProtocol(address _protocolAddress) 
        onlyReceiver(_protocolAddress) {
            Protocol p = Protocol(_protocolAddress);
            p.receive();
            // TODO - Fazer tratamento em caso de falha
            confirmOperation(true);
    }


    /// @notice Função do tipo call (não consome ether) que obtem conjunto de informações sobre um determinado contrato Protocolo.
    /// @param _enderecoDoProtocolo Endereço do protocolo a ser consultado.
    /// @dev Solidity não permite retorno de struct e objetos compostos
    /// @return Lista com os atributos e respectivos indices:
    /// @return 1 - Endereco do Autor 
    /// @return 2 - Situação do Protocolo (1- Aberto, 2- Aguardando Recebimento, 3 - Recebido, 4 - Cancelado)
    /// @return 3 - Tipo do Protocolo (a definir código)
    /// @return 4 - Endereco do Remetente
    /// @return 5 - Endereco do Destinatário
    /// @return 6 - Assunto do Protocolo
    /// @return 7 - Descrição do Protocolo
    /// @return 8 - TimeStamp da criação  do Protocolo
    /// @return 9 - TimeStamp da ultima operação  do Protocolo (envio/recebimento)
  function obterInfoProtocolo(address _protocolAddress) returns (address  _author,uint _status,uint protocolType,address _remetente,address _destinatario,bytes32  _assunto, bytes32 _descricao,uint _tempoCriacao,uint _tempoSituacao){
       // TODO - Fazer tratamento em caso de falha
       Protocol p = Protocol(_protocolAddress);

      _author=p.getAuthor();
      _situacao=p.obterSituacaoAtual(); 
      _remetente=p.obterRemetente();
      _destinatario=p.obterDestinatario();
      _tipoProtocolo=p.obterTipoProtocolo(); 
      _assunto=p.obterAssunto();
      _descricao=p.obterDescricao();
      _tempoCriacao=p.obterDataHoraCriacao();
      _tempoSituacao=p.obterDataHoraUltimaMovimentacao();

    }


    /// @notice Função do tipo call (não consome ether) que obtem variavel de controle quantidade de protocolos gerenciados.
    /// @return quantidade de protocolos gerenciados por este protocolo.
    function obterQuantidadeProtocolosGerenciados() returns (uint) {
       return quantidadeProtocolosGerenciados;
    }
    

   
}


// Contrato Protocolo 
// Contém estrutura de dados e operações de um protocolo básico

/// @title Gerenciador de protocolo.
/// @author Fabiano Alencar (332.186)
contract Protocol {

  address author;
  address manager; //endereço do contrato gerenciador
  address sender;
  address receiver;
  uint protocolType; //
  bytes32  subject;
  bytes32 description;
  uint creationTime;
  uint statusTime;
  Situacao status; // 1- Aberto, 2- Aguardando Recebimento, 3 - Recebido, 4 - Cancelado
  uint documentsQty;
  enum Status { Open, WaittingRece, Received ,Canceled } // Enum

   //Estrutura para armazenar os documentos anexados no protocolo
   struct  Document {
      bytes32  name;
      bytes32 location;
      bytes32 hashDocument;
   }

   // modifier para restringir acesso para somente o autor ou destinatário do Protocolo
   modifier permissaoStatusAberto()
    {
        if (situacao!=Situacao.Aberto)
            throw;
        _;
    }

    modifier permissaoStatusAguardandoRecebimento()
    {
        if (situacao!=Situacao.AguardandoRecebimento)
            throw;
        _;
    }

     modifier permissaoStatusRecebido()
    {
        if (situacao!=Situacao.Recebido)
            throw;
        _;
    }
    modifier permissaoStatusAbertoRecebido()
    {
        if (!(situacao==Situacao.Recebido ||situacao==Situacao.Aberto) )
            throw;
        _;
    } 

  Document[] documents;   
 
    //Constructor
  function Protocol(address _author, uint _protocolType, bytes32 _subject, bytes32 _description){
    manager = msg.sender;
    author = _author;
    protocolType = _protocolType;
    subject = _subject;
    status = Status.Open;
    description=_description;
    statusTime = block.timestamp;
    creationTime = block.timestamp;
    documentsQty=0;
  }

  function addDocument(bytes32 _documentName, bytes32 _location, bytes32 _hash) permissaoStatusAberto() {
    if((msg.sender==manager || msg.sender==author)){
      documentos.push(Documento(_documentName,_location,_hash));
      documentsQty+=1;
    }

  }  
 
  function removeDocument(uint _index) permissaoStatusAberto() {
    if(msg.sender==manager || msg.sender==author){
      delete documents[_index];
      documentsQty-=1;
    }

  }  

   function getDocument(uint _index) returns (bytes32  _name,bytes32 _location, bytes32 _hash){
    if(msg.sender==manager || tx.origin==author || tx.origin==receiver ) {
      
      Document doc=documents[_index];
      _nome=doc.nome;
      _localizacao=doc.localizacao;
      _hash=doc.hashDocumento;
    }

  }  
  


  function send(address _destinatario, bytes32 _descricao) permissaoStatusAberto() permissaoStatusAbertoRecebido() returns (bool){
    if(msg.sender==manager || msg.sender==author || msg.sender==receiver){
       remetente=autor;
       destinatario=_destinatario;
       situacao=Situacao.AguardandoRecebimento;
       tempoSituacao = block.timestamp;
       descricao=_descricao;
       return true; 
   }else{
      throw;
    }
     
  }

  function receive() permissaoStatusAguardandoRecebimento() returns (bool){
    if(msg.sender==manager || msg.sender==receiver){
      status=Status.Received;
      statusTime = block.timestamp;
      return true;
    }else{
      throw;
    }
      
  }

  function cancel() permissaoStatusAberto() {
    if(msg.sender==author || msg.sender==manager){
      situacao=Status.Canceled;
      statusTime = block.timestamp;
    }else{
      throw; 
    }
  }
  

  function getCurrentStatus() returns (uint){
      return uint(status);
  }
  
  function getAuthor() returns (address){
      return author;
  }
  
  function getSender() returns (address){
      return sender;
  }

  function getReceiver() returns (address){
      return receiver;
  }

  function getProtocolType() returns (uint){
      return protocolType;
  }

  function obterAssunto() returns (bytes32){
      return assunto;
  }

  function obterDescricao() returns (bytes32){
    return descricao;
  }
  
  function obterDataHoraCriacao() returns (uint){
    return tempoCriacao;
  }

  function obterDataHoraUltimaMovimentacao() returns (uint){
    return tempoSituacao;
  }

   function obterQuantidadeDocumentos() returns (uint){
    return qtdDocumentos;
  }
 
}

