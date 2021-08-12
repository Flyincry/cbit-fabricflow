/*
 * SPDX-License-Identifier: Apache-2.0
 */

package inventoryfinancingpaper

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Contract chaincode that defines
// the business logic for managing inventory paper

type Contract struct {
	contractapi.Contract
}

// Instantiate does nothing
func (c *Contract) Instantiate() {
	fmt.Println("Instantiated")
}

// Apply creates a new inventory paper and stores it in the world state
func (c *Contract) Apply(ctx TransactionContextInterface, paperNumber string, jeweler string, applyDateTime string, financingAmount int) (*InventoryFinancingPaper, error) {
	paper := InventoryFinancingPaper{PaperNumber: paperNumber, Jeweler: jeweler, ApplyDateTime: applyDateTime, FinancingAmount: financingAmount}
	paper.SetApplied()

	err := ctx.GetPaperList().AddPaper(&paper)

	if err != nil {
		return nil, err
	}

	return &paper, nil
}

// Receive updates a inventory paper to be in received status and sets the next dealer
func (c *Contract) Receive(ctx TransactionContextInterface, jeweler string, bank string, paperNumber string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.GetBank() == "" {
		paper.SetBank(bank)
	}

	if paper.IsApplied() {
		paper.SetReceived()
	}

	if !paper.IsReceived() {
		return nil, fmt.Errorf("inventory paper %s:%s is not received by bank. Current state = %s", jeweler, paperNumber, paper.GetState())
	}

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

//Evaluated updates a inventory paper to be in Evaluated status and sets the next dealer
func (c *Contract) Evaluate(ctx TransactionContextInterface, jeweler string, paperNumber string, evaluator string, evalDateTime error) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.GetEvaluator() == "" {
		paper.SetEvaluator(evaluator)
	}

	if paper.IsReceived() {
		paper.SetEvaluated()
	}

	if !paper.IsEvaluated() {
		return nil, fmt.Errorf("inventory paper %s:%s is not yet evaluated. Current state = %s", jeweler, paperNumber, paper.GetState())
	}

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

//ReadyRepo updates a inventory paper to be in ReadyRepo status and sets the next dealer
func (c *Contract) ReadyRepo(ctx TransactionContextInterface, jeweler string, paperNumber string, repurchaser string, readyDateTime error) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.GetRepurchaser() == "" {
		paper.SetRepurchaser(repurchaser)
	}

	if paper.IsEvaluated() {
		paper.SetReadyREPO()
	}

	if !paper.IsReadyREPO() {
		return nil, fmt.Errorf("inventory paper %s:%s is waiting for REPO's ready. Current state = %s", jeweler, paperNumber, paper.GetState())
	}

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

// Accept updates a inventory paper to be in accepted status and sets the next dealer
func (c *Contract) Accept(ctx TransactionContextInterface, jeweler string, paperNumber string, acceptDate string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.IsReadyREPO() {
		paper.SetAccepted()
	}

	if !paper.IsAccepted() {
		return nil, fmt.Errorf("inventory paper %s:%s is not accepted by bank. Current state = %s", jeweler, paperNumber, paper.GetState())
	}

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

// Supervising updates a inventory paper to be in supervising status and sets the next dealer
func (c *Contract) Supervise(ctx TransactionContextInterface, jeweler string, supervisor string, endDate string, paperNumber string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.GetSupervisor() == "" {
		paper.SetSupervisor(supervisor)
	}
	if paper.IsAccepted() {
		paper.SetSupervising()
	}

	if !paper.IsSupervising() {
		return nil, fmt.Errorf("inventory paper %s:%s is not in supervision. Current state = %s", jeweler, paperNumber, paper.GetState())
	}

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

// Payback updates a inventory paper status to be paidback
func (c *Contract) Payback(ctx TransactionContextInterface, jeweler string, paperNumber string, paidbackDateTime string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.IsPaidBack() {
		return nil, fmt.Errorf("paper %s:%s is already PaidBack", jeweler, paperNumber)
	}

	paper.SetPaidBack()

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

// Default updates a inventory paper status to be default
func (c *Contract) Default(ctx TransactionContextInterface, jeweler string, paperNumber string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.IsDefault() {
		return nil, fmt.Errorf("paper %s:%s can not be paidback", jeweler, paperNumber)
	}

	paper.SetDefault()

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}

// Repurchase updates a inventory paper status to be repurchsed
func (c *Contract) Repurchase(ctx TransactionContextInterface, jeweler string, paperNumber string, repurchaseDateTime string) (*InventoryFinancingPaper, error) {
	paper, err := ctx.GetPaperList().GetPaper(jeweler, paperNumber)

	if err != nil {
		return nil, err
	}

	if paper.IsPaidBack() {
		return nil, fmt.Errorf("paper %s:%s is already Repurchased", jeweler, paperNumber)
	}

	paper.SetPaidBack()

	err = ctx.GetPaperList().UpdatePaper(paper)

	if err != nil {
		return nil, err
	}

	return paper, nil
}
