/*
 * SPDX-License-Identifier: Apache-2.0
 */

package inventoryfinancingpaper

import (
	"encoding/json"
	"fmt"

	ledgerapi "github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/contract-go/ledger-api"
)

// State enum for inventory financing  state property
type State uint

const (
	APPLIED = iota + 1
	RECEIVED
	EVALUATED
	READYREPO
	ACCEPTED
	SUPERVISING
	PAIDBACK
	DEFAULT
	REPURCHADED
)

func (state State) String() string {
	names := []string{"APPLIED ", "RECEIVED", "EVALUATED", "READYREPO", "ACCEPTED", "SUPERVISING", "PAIDBACK", "DEFAULT", "REPURCHADED"}

	if state < APPLIED || state > REPURCHADED {
		return "UNKNOWN"
	}

	return names[state-1]
}

// CreateInventoryFinancingPaperKey creates a key for inventory financing
func CreateInventoryFinancingPaperKey(jeweler string, paperNumber string) string {
	return ledgerapi.MakeKey(jeweler, paperNumber)
}

// Used for managing the fact status is private but want it in world state
type InventoryFinancingPaperAlias InventoryFinancingPaper
type jsonInventoryFinancingPaper struct {
	*InventoryFinancingPaperAlias
	State State  `json:"currentState"`
	Class string `json:"class"`
	Key   string `json:"key"`
}

// InventoryFinancingPaper defines a commercial paper
type InventoryFinancingPaper struct {
	PaperNumber        string `json:"paperNumber"`
	Jeweler            string `json:"jeweler"`
	ApplyDateTime      string `json:"applyDateTime"`
	ReviseDateTime     string `json:"reviseDateTime"`
	AcceptDateTime     string `json:"acceptDateTime"`
	ReadyDateTime      string `json:"readyDateTime"`
	EvalDateTime       string `json:"evalDateTime"`
	ReceiveDateTime    string `json:"receiveDateTime"`
	EndDate            string `json:"endDateTime"`
	PaidbackDateTime   string `json:"paidBackDateTime"`
	RepurchaseDateTime string `json:"RepurchaseDateTime"`
	FinancingAmount    int    `json:"financingAmount"`
	Dealer             string `json:"dealer"`
	state              State  `metadata:"currentState"`
	prevstate          State  `metadata:"prevState,optional"`
	class              string `metadata:"class"`
	key                string `metadata:"key"`
	Bank               string `json:"bank"`
	Evaluator          string `json:"evaluator"`
	Repurchaser        string `json:"repurchaser"`
	Supervisor         string `json:"supervisor"`
}

// UnmarshalJSON special handler for managing JSON marshalling
func (ifc *InventoryFinancingPaper) UnmarshalJSON(data []byte) error {
	jifc := jsonInventoryFinancingPaper{InventoryFinancingPaperAlias: (*InventoryFinancingPaperAlias)(ifc)}

	err := json.Unmarshal(data, &jifc)

	if err != nil {
		return err
	}

	ifc.state = jifc.State

	return nil
}

// MarshalJSON special handler for managing JSON marshalling
func (ifc InventoryFinancingPaper) MarshalJSON() ([]byte, error) {
	jifc := jsonInventoryFinancingPaper{InventoryFinancingPaperAlias: (*InventoryFinancingPaperAlias)(&ifc), State: ifc.state, Class: "org.papernet.InventoryFinancingPaper", Key: ledgerapi.MakeKey(ifc.Jeweler, ifc.PaperNumber)}

	return json.Marshal(&jifc)
}

// GetState returns the state
func (ifc *InventoryFinancingPaper) GetState() State {
	return ifc.state
}

// SetPrevState returns the previous state
func (ifc *InventoryFinancingPaper) LogPrevState() State {
	ifc.prevstate = ifc.state
	return ifc.prevstate
}

// Get prev state and set as curr state
func (ifc *InventoryFinancingPaper) Reinstate() State {
	ifc.state = ifc.prevstate
	return ifc.state
}

// GetBank returns the bank
func (ifc *InventoryFinancingPaper) GetBank() string {
	return ifc.Bank
}

// GetAcceptDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetAcceptDateTime() string {
	return ifc.AcceptDateTime
}

// GetReceiveDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetReceiveDateTime() string {
	return ifc.ReceiveDateTime
}

// GetEvaluator returns the evaluator
func (ifc *InventoryFinancingPaper) GetEvaluator() string {
	return ifc.Evaluator
}

// GetEvalDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetEvalDateTime() string {
	return ifc.EvalDateTime
}

// GetRepurchaser returns the repurchaser
func (ifc *InventoryFinancingPaper) GetRepurchaser() string {
	return ifc.Repurchaser
}

// GetReadyDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetReadyDateTime() string {
	return ifc.ReadyDateTime
}

// GetSupervisor returns the supervisor
func (ifc *InventoryFinancingPaper) GetSupervisor() string {
	return ifc.Supervisor
}

// GetAcceptDateTime returns the acceptdatetime
func (ifc *InventoryFinancingPaper) GetApplyDateTime() string {
	return ifc.ApplyDateTime
}

// GetEndDate returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetEndDate() string {
	return ifc.EndDate
}

// GetPaidbackDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetPaidbackDateTime() string {
	return ifc.PaidbackDateTime
}

// GetRepurchaseDateTime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetRepurchaseDateTime() string {
	return ifc.RepurchaseDateTime
}

// GetReviseDatetime returns the receivedatetime
func (ifc *InventoryFinancingPaper) GetReviseDatetime() string {
	return ifc.ReviseDateTime
}

// SetBank set the Bank to bank
func (ifc *InventoryFinancingPaper) SetBank(bank string) {
	ifc.Bank = bank
}

//SetReceiveDateTime set the ReceiveDateTime to receiveDateTime
func (ifc *InventoryFinancingPaper) SetReceiveDateTime(receiveDateTime string) {
	ifc.ReceiveDateTime = receiveDateTime
}

// SetEvaluator set the Evaluator to evaluator
func (ifc *InventoryFinancingPaper) SetEvaluator(evaluator string) {
	ifc.Evaluator = evaluator
}

//SetEvalDateTime set the EvalDateTime to evalDateTime
func (ifc *InventoryFinancingPaper) SetEvalDateTime(evalDateTime string) {
	ifc.EvalDateTime = evalDateTime
}

// SetRepurchaser set the Repurchaser to repurchaser
func (ifc *InventoryFinancingPaper) SetRepurchaser(repurchaser string) {
	ifc.Repurchaser = repurchaser
}

//SetReadyDateTime set the ReadyDateTime to receiveDateTime
func (ifc *InventoryFinancingPaper) SetApplyDateTime(applyDateTime string) {

	ifc.ApplyDateTime = applyDateTime
}

//SetReadyDateTime set the ReadyDateTime to receiveDateTime
func (ifc *InventoryFinancingPaper) SetReadyDateTime(readyDateTime string) {
	ifc.ReadyDateTime = readyDateTime
}

//SetAcceptDateTime set the ApplyDateTime to the apllyDateTime
func (ifc *InventoryFinancingPaper) SetAcceptDateTime(acceptDateTime string) {
	ifc.ReadyDateTime = acceptDateTime
}

// SetEndDate set the EndDate to endDate
func (ifc *InventoryFinancingPaper) SetEndDate(endDate string) {
	ifc.EndDate = endDate
}

// SetPaidbackDateTime set the Paidbackdatetime to paidbackDateTime
func (ifc *InventoryFinancingPaper) SetPaidbackDateTime(paidbackDateTime string) {
	ifc.PaidbackDateTime = paidbackDateTime
}

// SetRepurchaseDateTime set the repurchaseatetime
func (ifc *InventoryFinancingPaper) SetRepurchaseDateTime(repurchaseDateTime string) {
	ifc.RepurchaseDateTime = repurchaseDateTime
}

// SetReviseDatetime set the recisedatetime
func (ifc *InventoryFinancingPaper) SetReviseDatetime(reviseDateTime string) {
	ifc.ReviseDateTime = reviseDateTime
}

// SetSupervisor set the state to supervisor
func (ifc *InventoryFinancingPaper) SetSupervisor(supervisor string) {
	ifc.Supervisor = supervisor
}

// SetApplied set the state to applied
func (ifc *InventoryFinancingPaper) SetApplied() {
	ifc.state = APPLIED
}

// SetReceived sets the state to received
func (ifc *InventoryFinancingPaper) SetReceived() {
	ifc.state = RECEIVED
}

// SetAccepted sets the state to accepted
func (ifc *InventoryFinancingPaper) SetAccepted() {
	ifc.state = ACCEPTED
}

// SetSupervising sets the state to supervising
func (ifc *InventoryFinancingPaper) SetSupervising() {
	ifc.state = SUPERVISING
}

// SetPaidBack sets the state to paidBack
func (ifc *InventoryFinancingPaper) SetPaidBack() {
	ifc.state = PAIDBACK
}

// SetDefault sets the state to default
func (ifc *InventoryFinancingPaper) SetDefault() {
	ifc.state = DEFAULT
}

// SetRepurchased sets the state to repurchased
func (ifc *InventoryFinancingPaper) SetRepurchased() {
	ifc.state = REPURCHADED
}

// IsApplied returns true if state is APPLIED
func (ifc *InventoryFinancingPaper) IsApplied() bool {
	return ifc.state == APPLIED
}

// IsReceived returns true if state is RECEIVED
func (ifc *InventoryFinancingPaper) IsReceived() bool {
	return ifc.state == RECEIVED
}

// IsAccepted returns true if state is Accepted
func (ifc *InventoryFinancingPaper) IsAccepted() bool {
	return ifc.state == ACCEPTED
}

// Supervising returns true if state is Supervising
func (ifc *InventoryFinancingPaper) IsSupervising() bool {
	return ifc.state == SUPERVISING
}

// IsPaidBack returns true if state is PaidBack
func (ifc *InventoryFinancingPaper) IsPaidBack() bool {
	return ifc.state == PAIDBACK
}

// IsDefault returns true if state is Default
func (ifc *InventoryFinancingPaper) IsDefault() bool {
	return ifc.state == DEFAULT
}

// IsRepurchased returns true if state is Repurchased
func (ifc *InventoryFinancingPaper) IsRepurchased() bool {
	return ifc.state == REPURCHADED
}

// IsRejectable returns true if state is in RECEIVED EVALUATED READYREPO
func (ifc *InventoryFinancingPaper) IsRejectable() bool {
	var ret bool = false

	if ifc.state == RECEIVED {
		ret = true
	}

	if ifc.state == EVALUATED {
		ret = true
	}

	if ifc.state == READYREPO {
		ret = true
	}
	return ret
}

// GetSplitKey returns values which should be used to form key
func (ifc *InventoryFinancingPaper) GetSplitKey() []string {
	return []string{ifc.Jeweler, ifc.PaperNumber}
}

// Serialize formats the inventory financing  as JSON bytes
func (ifc *InventoryFinancingPaper) Serialize() ([]byte, error) {
	return json.Marshal(ifc)
}

// Deserialize formats the Inventory Financing  from JSON bytes
func Deserialize(bytes []byte, ifc *InventoryFinancingPaper) error {
	err := json.Unmarshal(bytes, ifc)

	if err != nil {
		return fmt.Errorf("error deserializing inventory financing . %s", err.Error())
	}

	return nil
}
