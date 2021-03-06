//
//  DatabaseApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

private typealias AccountsService = DatabaseApiServiceImp
private typealias GlobalsService = DatabaseApiServiceImp
private typealias AssetsService = DatabaseApiServiceImp
private typealias SubscriptionService = DatabaseApiServiceImp
private typealias AuthorityAndValidationService = DatabaseApiServiceImp
private typealias BlocksAndTransactionsService = DatabaseApiServiceImp
private typealias ContractsService = DatabaseApiServiceImp

/**
     Implementation of [DatabaseApiService](DatabaseApiService)

     Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class DatabaseApiServiceImp: DatabaseApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
}

extension AccountsService {
    
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[String: UserAccount]>) {
        
        let operation = FullAccountSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   accountsIds: nameOrIds,
                                                   shoudSubscribe: shoudSubscribe,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension GlobalsService {
    
    func getChainId(completion: @escaping Completion<String>) {
        
        let operation = GetChainIdSocketOperation(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getObjects<T>(type: T.Type, objectsIds: [String], completion: @escaping Completion<[T]>) where T: Decodable {
        
        let operation = GetObjectsSocketOperation<T>(method: .call,
                                                     operationId: socketCore.nextOperationId(),
                                                     apiId: apiIdentifire,
                                                     identifiers: objectsIds,
                                                     completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension AuthorityAndValidationService {
    
    func getRequiredFees(operations: [BaseOperation], asset: Asset, completion: @escaping Completion<[AssetAmount]>) {
        
        let operation = RequiredFeeSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   operations: operations,
                                                   asset: asset,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension BlocksAndTransactionsService {
    
    func getBlockData(completion: @escaping Completion<BlockData>) {
        
        let operation = BlockDataSocketOperation(method: .call, operationId: socketCore.nextOperationId(), apiId: apiIdentifire) { (result) in
            switch result {
            case .success(let dynamicProperties):
                
                let headBlockId = dynamicProperties.headBlockId
                let headBlockNumber = dynamicProperties.headBlockNumber
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = Settings.defaultDateFormat
                dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
                
                let date = dateFormatter.date(from: dynamicProperties.time)
                let interval = date?.timeIntervalSince1970 ?? 0
                let expirationTime = Int(interval) + Transaction.defaultExpirationTime
                
                let blockData = BlockData(headBlockNumber: headBlockNumber, headBlockId: headBlockId, relativeExpiration: expirationTime)
                let result = Result<BlockData, ECHOError>(value: blockData)
                completion(result)
            case .failure(let error):
                let result = Result<BlockData, ECHOError>(error: error)
                completion(result)
            }
        }
        
        socketCore.send(operation: operation)
    }
    
    func getBlock(blockNumber: Int, completion:@escaping Completion<Block>) {
        
        let operation = GetBlockSocketOperation(method: .call,
                                                operationId: socketCore.nextOperationId(),
                                                apiId: apiIdentifire,
                                                blockNumber: blockNumber,
                                                completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension SubscriptionService {
    
    func setSubscribeCallback(completion: @escaping Completion<Bool>) {
        let operation = SetSubscribeCallbackSocketOperation(method: .call,
                                                            operationId: socketCore.nextOperationId(),
                                                            apiId: apiIdentifire,
                                                            needClearFilter: false,
                                                            completion: completion)
        socketCore.send(operation: operation)
    }
    
    func setBlockAppliedCallback(blockId: String, completion: @escaping Completion<Bool>) {
        
        let operation = SetBlockAppliedCollbackSocketOperation(method: .call,
                                                               operationId: socketCore.nextOperationId(),
                                                               apiId: apiIdentifire,
                                                               blockId: blockId,
                                                               completion: completion)
        socketCore.send(operation: operation)
    }
}

extension AssetsService {
    
    func getAssets(assetIds: [String], completion: @escaping Completion<[Asset]>) {
        
        let operation = GetAssetsSocketOperation(method: .call,
                                                 operationId: socketCore.nextOperationId(),
                                                 apiId: apiIdentifire,
                                                 assestsIds: assetIds,
                                                 completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>) {
        let operation = ListAssetsSocketOperation(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  lowerBound: lowerBound,
                                                  limit: limit,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension ContractsService {
    
    func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>) {
        
        let operation = GetContractResultSocketOperation(method: .call,
                                                         operationId: socketCore.nextOperationId(),
                                                         apiId: apiIdentifire,
                                                         historyId: historyId,
                                                         completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>) {
        
        let operation = GetContractsSocketOperation(method: .call,
                                                    operationId: socketCore.nextOperationId(),
                                                    apiId: apiIdentifire,
                                                    contractIds: contractIds,
                                                    completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getAllContracts(completion: @escaping Completion<[ContractInfo]>) {
        
        let operation = GetAllContractsSocketOperation(method: .call,
                                                       operationId: socketCore.nextOperationId(),
                                                       apiId: apiIdentifire,
                                                       completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getContract(contractId: String, completion: @escaping Completion<ContractStruct>) {
        
        let operation = GetContractSocketOperaton(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  contractId: contractId,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func callContractNoChangingState(contract: Contract,
                                     asset: Asset,
                                     account: Account,
                                     contractCode: String,
                                     completion: @escaping Completion<String>) {
        
        let operation = QueryContractSocketOperation(method: .call,
                                                    operationId: socketCore.nextOperationId(),
                                                    apiId: apiIdentifire,
                                                    contractId: contract.id,
                                                    registrarId: account.id,
                                                    assetId: asset.id,
                                                    code: contractCode,
                                                    completion: completion)
        
        socketCore.send(operation: operation)
    }
}
