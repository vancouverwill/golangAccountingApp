package models

import (
	"fmt"
	"log"
)

type TaxRate struct {
	Id      int     `json:"id"`
	Name    string  `json:"name"`
	TaxRate float32 `json:"taxRate"` // e.g. 0.13 is equal to 13 percent
	Updated int     `json:"updated"`
	Created int     `json:"created"`
}

func GetTaxRateByName(name string) TaxRate {
	log.Println("getTaxRateByName")
	db, e := myDb.setup()
	defer db.Close()
	if e != nil {
		fmt.Print(e)
	}
	var (
		id      int
		taxRate float32
	)
	err := db.QueryRow("SELECT t.id, t.taxRate FROM taxRates AS t WHERE t.name = ?", name).Scan(&id, &taxRate)
	if err != nil {
		fmt.Print(err)
	}

	taxRateObject := TaxRate{Id: id, Name: name, TaxRate: taxRate}

	return taxRateObject
}

func GetTaxRateByAccountHolderId(accountHolderId int) TaxRate {
	log.Println("GetTaxRateByAccountHolderId", accountHolderId)
	db, e := myDb.setup()
	defer db.Close()
	if e != nil {
		fmt.Print(e)
	}
	var (
		id      int
		name    string
		taxRate float32
	)
	selectStatement := "SELECT t.id, t.name AS name, t.taxRate FROM taxRates AS t "
	selectStatement += " JOIN accountHolders AS ah ON ah.taxRateId = t.id "
	selectStatement += "WHERE ah.id = ?"
	err := db.QueryRow(selectStatement, accountHolderId).Scan(&id, &name, &taxRate)
	if err != nil {
		fmt.Print(err)
	}

	taxRateObject := TaxRate{Id: id, Name: name, TaxRate: taxRate}

	log.Println("Id:", id, "Name:", name, "TaxRate:", taxRate)

	return taxRateObject
}
