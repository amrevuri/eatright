/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Trade Finance Use Case - WORK IN  PROGRESS
 */

package main


import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}


// Define the letter of credit
/*
type LetterOfCredit struct {
	LCId			string		`json:"lcId"`
	ExpiryDate		string		`json:"expiryDate"`
	Buyer    string   `json:"buyer"`
	Bank		string		`json:"bank"`
	Seller		string		`json:"seller"`
	Amount			int		`json:"amount,int"`
	Status			string		`json:"status"`
}
*/
type TunaFish struct {
	fishId   string `json:fishId`
	fishType   string `json:fishType`
	sourceLoc  string `json:sourceLoc`
	dimension  string `json:dimension`
	weight     string  `json:weight`
	merchant   string  `json:merchant` 
	certified    bool    `json:certify`
	loadTime   string  `json:loadTime`
	deliverTime string `json:deliverTime`
	ack        bool    `json:ack`
	ackTime    string  `json:ackTime`
}

/*
type RegulatoryChecks {
	inspectorId string `json:inspectorId`
	hazardsChecks bool `json:hazardsInvoled`
	ccpChecks bool `json:ccpChecks`
	criticalLimitChecks bool `json:criticalLiimtChecks`
	sanitationChecks bool `json:sanitationChecks`
	importerChecks bool `json:importerChecks`
}

type Merchant struct {
	merchantId string `merchantId`
	name       string `name`
	address    string `address`
        zip        string `zip`	
}

type Logistics struct {
	carrierId string `json:carrierId`
	carrierName string `json:carrierName`
	containerId string `json:containerId`
	loadTime Time `json:loadTime`
	unloadTime Time `json:unloadTime`
}
*/

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	// EatFresh functions

	if function == "recordFish" {
		return s.recordFish(APIstub, args)
	} else if function == "certifyFish" {
		return s.certifyFish(APIstub, args)
	} else if function == "loadFish" {
		return s.loadFish(APIstub, args)
	}else if function == "deliverFish" {
		return s.deliverFish(APIstub, args)
	}else if function == "ackDelivery" {
		return s.ackDelivery(APIstub, args)
	}else if function == "getDeliveryHistory" {
		return s.getDeliveryHistory(APIstub, args)
	}else if function == "getFish" {
		return s.getFish(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}


func (s *SmartContract) recordFish(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	
	fish := TunaFish{}

	err  := json.Unmarshal([]byte(args[0]),&fish)
        if err != nil {
		return shim.Error("Unable to parse args")
	}

	fishBytes, err := json.Marshal(fish)
        APIstub.PutState(fish.fishId,fishBytes)
	
	fmt.Println("Fish Recorded -> ", fish)
	return shim.Success(nil)
}

func (s *SmartContract) certifyFish(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {

	//Create Temp Struct
	fishID := struct {
		id  string `json:"fishId"`
	}{}
	
	err  := json.Unmarshal([]byte(args[0]),&fishID)

	if err != nil {
		return shim.Error("Not able to parse args into Fish Id")
	}
	
        //Get fish details
	fishBytes, _ := APIstub.GetState(fishID.id)

	var tf TunaFish; 
 
	err = json.Unmarshal(fishBytes, &tf)

	if err != nil {
		return shim.Error("Error while retrieving fish details to certify")
	}


	tunaFish := TunaFish {fishId:tf.fishId, fishType:tf.fishType, sourceLoc:tf.sourceLoc, dimension:tf.dimension, weight:tf.weight,merchant:tf.merchant, certified:true, loadTime:tf.loadTime, deliverTime:tf.deliverTime, ack:tf.ack, ackTime:tf.ackTime}
	updatedFishBytes, err := json.Marshal(tunaFish)

	if err != nil {
		return shim.Error("Issue with Tuna  json marshaling")
	}

        APIstub.PutState(tunaFish.fishId,updatedFishBytes)
	fmt.Println("Fish Certified -> ", updatedFishBytes)

	return shim.Success(nil)
}

func (s *SmartContract) loadFish(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	//Create Temp Struct
	fishID := struct {
		id  string `json:"fishId"`
	}{}
	err  := json.Unmarshal([]byte(args[0]),&fishID)

	if err != nil {
		return shim.Error("Not able to parse args into Fish Id")
	}
	
        //Get fish details
	fishBytes, _ := APIstub.GetState(fishID.id)

	var tf TunaFish; 
 
	err = json.Unmarshal(fishBytes, &tf)

	if err != nil {
		return shim.Error("Error while retrieving loading fish details")
	}

        currentTime := time.Now();
	tunaFish := TunaFish {fishId:tf.fishId, fishType:tf.fishType, sourceLoc:tf.sourceLoc, dimension:tf.dimension, weight:tf.weight,merchant:tf.merchant, certified:tf.certified, loadTime:currentTime.Format("YYYY-MM-DD hh:mm:ss"), deliverTime:tf.deliverTime, ack:tf.ack, ackTime:tf.ackTime}
	updatedFishBytes, err := json.Marshal(tunaFish)

	if err != nil {
		return shim.Error("Issue with Tuna  json marshaling")
	}

        APIstub.PutState(tunaFish.fishId,updatedFishBytes)
	fmt.Println("Fish Loaded to Container -> ", updatedFishBytes)

	
	return shim.Success(nil)
}

func (s *SmartContract) deliverFish(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	
	//Create Temp Struct
	fishID := struct {
		id  string `json:"fishId"`
	}{}
	err  := json.Unmarshal([]byte(args[0]),&fishID)

	if err != nil {
		return shim.Error("Not able to parse args into Fish Id")
	}
	
        //Get fish details
	fishBytes, _ := APIstub.GetState(fishID.id)

	var tf TunaFish; 
 
	err = json.Unmarshal(fishBytes, &tf)

	if err != nil {
		return shim.Error("Error while retrieving loading fish details")
	}

        currentTime := time.Now();

	tunaFish := TunaFish {fishId:tf.fishId, fishType:tf.fishType, sourceLoc:tf.sourceLoc, dimension:tf.dimension, weight:tf.weight, merchant:tf.merchant, certified:tf.certified, loadTime:tf.loadTime, deliverTime:currentTime.Format("YYYY-MM-DD hh:mm:ss"), ack:tf.ack, ackTime:tf.ackTime}
	updatedFishBytes, err := json.Marshal(tunaFish)

	if err != nil {
		return shim.Error("Issue with Tuna  json marshaling")
	}

        APIstub.PutState(tunaFish.fishId,updatedFishBytes)
	fmt.Println("Fish Loaded to Container -> ", updatedFishBytes)

	
	return shim.Success(nil)
}

func (s *SmartContract) ackDelivery(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	//Create Temp Struct
	fishID := struct {
		id  string `json:"fishId"`
	}{}
	err  := json.Unmarshal([]byte(args[0]),&fishID)

	if err != nil {
		return shim.Error("Not able to parse args into Fish Id")
	}
	
        //Get fish details
	fishBytes, _ := APIstub.GetState(fishID.id)

	var tf TunaFish; 
 
	err = json.Unmarshal(fishBytes, &tf)

	if err != nil {
		return shim.Error("Error while retrieving loading fish details")
	}

        currentTime := time.Now();

	tunaFish := TunaFish {fishId:tf.fishId, fishType:tf.fishType, sourceLoc:tf.sourceLoc, dimension:tf.dimension, weight:tf.weight,merchant:tf.merchant, certified:tf.certified, loadTime:tf.loadTime, deliverTime:tf.deliverTime, ack:true, ackTime:currentTime.Format("YYYY-MM-DD hh:mm:ss")}
	updatedFishBytes, err := json.Marshal(tunaFish)

	if err != nil {
		return shim.Error("Issue with Tuna  json marshaling")
	}

        APIstub.PutState(tunaFish.fishId,updatedFishBytes)
	fmt.Println("Fish Loaded to Container -> ", updatedFishBytes)

	
	
	return shim.Success(nil)
}

func (s *SmartContract) getFish(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	
	fishId := args[0];
	
	fishBytes, _ := APIstub.GetState(fishId)

	return shim.Success(fishBytes)
}

func (s *SmartContract) getDeliveryHistory(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {
	
	fishId := args[0];
	resultsIterator, err := APIstub.GetHistoryForKey(fishId)
	if err != nil {
		return shim.Error("Error retrievng Fish delivery history.")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error("Error retrieving Fish delivery history.")
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getDeliveryHistory returning:\n%s\n", buffer.String())


	return shim.Success(buffer.Bytes())
}
/*
// This function is initiate by Buyer 
func (s *SmartContract) requestLC(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {


	LC := LetterOfCredit{}

	err  := json.Unmarshal([]byte(args[0]),&LC)
if err != nil {
		return shim.Error("Not able to parse args into LC")
	}
	LCBytes, err := json.Marshal(LC)
        APIstub.PutState(LC.LCId,LCBytes)
	fmt.Println("LC Requested -> ", LC)
	return shim.Success(nil)
}

// This function is initiate by Seller
func (s *SmartContract) issueLC(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	lcID := struct {
		LcID  string `json:"lcID"`
	}{}
	err  := json.Unmarshal([]byte(args[0]),&lcID)
	if err != nil {
		return shim.Error("Not able to parse args into LCID")
	}
	
	// if err != nil {
	// 	return shim.Error("No Amount")
	// }

	LCAsBytes, _ := APIstub.GetState(lcID.LcID)

	var lc LetterOfCredit

	err = json.Unmarshal(LCAsBytes, &lc)

	if err != nil {
		return shim.Error("Issue with LC json unmarshaling")
	}


	LC := LetterOfCredit{LCId: lc.LCId, ExpiryDate: lc.ExpiryDate, Buyer: lc.Buyer, Bank: lc.Bank, Seller: lc.Seller, Amount: lc.Amount, Status: "Issued"}
	LCBytes, err := json.Marshal(LC)

	if err != nil {
		return shim.Error("Issue with LC json marshaling")
	}

    APIstub.PutState(lc.LCId,LCBytes)
	fmt.Println("LC Issued -> ", LC)


	return shim.Success(nil)
}

func (s *SmartContract) acceptLC(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	lcID := struct {
		LcID  string `json:"lcID"`
	}{}
	err  := json.Unmarshal([]byte(args[0]),&lcID)
	if err != nil {
		return shim.Error("Not able to parse args into LC")
	}

	LCAsBytes, _ := APIstub.GetState(lcID.LcID)

	var lc LetterOfCredit

	err = json.Unmarshal(LCAsBytes, &lc)

	if err != nil {
		return shim.Error("Issue with LC json unmarshaling")
	}


	LC := LetterOfCredit{LCId: lc.LCId, ExpiryDate: lc.ExpiryDate, Buyer: lc.Buyer, Bank: lc.Bank, Seller: lc.Seller, Amount: lc.Amount, Status: "Accepted"}
	LCBytes, err := json.Marshal(LC)

	if err != nil {
		return shim.Error("Issue with LC json marshaling")
	}

    APIstub.PutState(lc.LCId,LCBytes)
	fmt.Println("LC Accepted -> ", LC)


	

	return shim.Success(nil)
}

func (s *SmartContract) getLC(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	lcId := args[0];
	
	// if err != nil {
	// 	return shim.Error("No Amount")
	// }

	LCAsBytes, _ := APIstub.GetState(lcId)

	return shim.Success(LCAsBytes)
}

func (s *SmartContract) getLCHistory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	lcId := args[0];
	resultsIterator, err := APIstub.GetHistoryForKey(lcId)
	if err != nil {
		return shim.Error("Error retrieving LC history.")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error("Error retrieving LC history.")
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getLCHistory returning:\n%s\n", buffer.String())

	

	return shim.Success(buffer.Bytes())
}
*/
// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
