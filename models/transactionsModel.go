package models

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"time"
)

type Transaction struct {
	Id              int       `json:"id"`
	AccountTypeId   int       `json:"accountTypeId"`
	AccountHolderId int       `json:"accountHolderId"`
	Details         string    `json:"details"`
	Amount          float32   `json:"amount"` // saved as US dollars
	Date            time.Time `json:"date"`
	Updated         int       `json:"updated"`
	Created         int       `json:"created"`
}

type TransactionViewable struct {
	Transaction
	AccountType string `json:"accountType"`
}

type TransactionViewables []TransactionViewable
type Transactions []Transaction

/**
*
* amount is recorded as US dollars
*
**/
func (t Transaction) SaveTransaction() {
	log.Println("RepoCreateTransaction")
	log.Println(t)

	db, e := myDb.setup()
	defer db.Close()

	if e != nil {
		fmt.Print(e)
	}

	stmt, err := db.Prepare("INSERT INTO transactions (accountHolderId, AccountTypeId, details, amount, date, updated, created) values (?, ?, ?, ?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())")
	if err != nil {
		fmt.Print(err)
	}
	res, err := stmt.Exec(t.AccountHolderId, t.AccountTypeId, t.Details, t.Amount, t.Date)
	if err != nil {
		log.Fatal(err)
	}

	lastId, err := res.LastInsertId()
	if err != nil {
		log.Fatal(err)
	}
	RowsAffected, err := res.RowsAffected()
	if err != nil {
		log.Fatal(err)
	}
	log.Println("RowsAffected", RowsAffected)
	t.Id = int(lastId)
	log.Println("transaction entered")
	log.Println(t)
}

/**
*
* get all transactions
*
**/
func GetTransactions() TransactionViewables {
	log.Println("GetTransactions")
	db, e := myDb.setup()
	defer db.Close()

	if e != nil {
		fmt.Print(e)
	}

	selectStatement := "SELECT t.id, t.accountTypeId, t.AccountHolderId, t.details, t.amount, t.date, a.type AS accountType FROM transactions AS t "
	selectStatement += "JOIN accountTypes AS a ON a.id = t.accountTypeId"

	rows, err := db.Query(selectStatement)
	if err != nil {
		fmt.Print(err)
	}

	var results = make([]TransactionViewable, 0)

	i := 0
	for rows.Next() {

		var (
			id              int
			accountTypeId   int
			accountHolderId int
			details         string
			amount          float32
			accountType     string
			date            string
		)
		var err = rows.Scan(&id, &accountTypeId, &accountHolderId, &details, &amount, &date, &accountType)

		layout := "2006-01-02"

		dateString, err := time.Parse(layout, date)
		if err != nil {
			fmt.Println(err)
		}
		transaction := TransactionViewable{Transaction{Id: id, AccountTypeId: accountTypeId, AccountHolderId: accountHolderId, Details: details, Amount: amount, Date: dateString}, accountType}
		results = append(results, transaction)
		i++
	}

	return results
}

/**
*
* get transaction by transaction id
*
**/
func GetTransaction(transactionId int) Transaction {
	db, e := myDb.setup()
	defer db.Close()
	if e != nil {
		fmt.Print(e)
	}
	var (
		id              int
		accountTypeId   int
		accountHolderId int
		details         string
		amount          float32
		date            time.Time
	)
	err := db.QueryRow("SELECT id, accountTypeId, accountHolderId,  details, amount, date FROM transactions WHERE id = ?", transactionId).Scan(&id, &accountTypeId, &accountHolderId, &details, &amount, &date)
	if err != nil {
		fmt.Print(err)
	}

	transaction := Transaction{Id: id, AccountTypeId: accountTypeId, AccountHolderId: accountHolderId, Details: details, Amount: amount, Date: date}

	return transaction
}

/**
*
* get transaction by account holde id
*
**/
func GetTransactionsForAccountHolderId(accountHolderId int) TransactionViewables {
	log.Println("GetTransactionsForAccountHolderId", accountHolderId)

	db, e := myDb.setup()
	defer db.Close()

	if e != nil {
		fmt.Print(e)
	}

	selectStatement := "SELECT t.id, t.accountTypeId, t.accountHolderIdm t.details, a.type AS accountType, t.amount, t.date "
	selectStatement += "FROM transactions AS t "
	selectStatement += "JOIN accountTypes AS a ON a.id = t.accountTypeId "
	selectStatement += "WHERE a.accountHolderId = ? "

	rows, err := db.Query(selectStatement, accountHolderId)
	if err != nil {
		fmt.Print(err)
	}

	var results = make([]TransactionViewable, 0)

	i := 0
	for rows.Next() {

		var (
			id              int
			accountHolderId int
			accountTypeId   int
			details         string
			amount          float32
			date            string
		)
		var err = rows.Scan(&id, &details, &accountHolderId, &accountTypeId, &amount, &date)

		layout := "2006-01-02"

		dateString, err := time.Parse(layout, date)
		if err != nil {
			fmt.Println(err)
		}
		transaction := Transaction{Id: id, AccountTypeId: accountTypeId, AccountHolderId: accountHolderId, Details: details, Amount: amount, Date: dateString}
		transactionViewable := TransactionViewable{transaction, ""}
		results = append(results, transactionViewable)
		i++
	}
	log.Println(results)

	return results
}

func SaveTransactionByType(accountHolderId int, AccountType string, amount float32, details string) {

	if AccountType != "payment" && AccountType != "revenue" && AccountType != "tax" && AccountType != "commission" {
		panic(fmt.Sprintf("AccountType is not valid %v", AccountType))
	}
	db, e := myDb.setup()
	defer db.Close()

	if e != nil {
		fmt.Print(e)
	}

	stmt, err := db.Prepare("INSERT INTO transactions (accountHolderId, accountTypeId, details, amount, date, updated, created) values (?, (SELECT id FROM accountTypes WHERE type = ?), ?, ?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())")
	if err != nil {
		fmt.Print(err)
		log.Println(err)
	}
	res, err := stmt.Exec(accountHolderId, AccountType, details, amount, time.Now())
	if err != nil {
		log.Fatal(err)
	}

	lastId, err := res.LastInsertId()
	if err != nil {
		log.Fatal(err)
	}
	RowsAffected, err := res.RowsAffected()
	if err != nil {
		log.Fatal(err)
	}
	log.Println("RowsAffected", RowsAffected)
	log.Println("transaction entered", lastId)
}

//deleteTransaction(transaction_id int)
