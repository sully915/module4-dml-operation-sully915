/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Kelly Sullivan
 */


@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account ' + System.currentTimeMillis(); // Using current time for uniqueness
        newAccount.Industry = 'Technology';

        // Insert the Account into the database
        insert newAccount;

        // Return the Id of the newly created Account
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline

        Account newAccount1 = new Account();
        newAccount1.Name = name;
        newAccount1.Industry = industry;

        // Insert the Account
        insert newAccount1;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;

        // Insert the Contact into the database
        insert newContact;

        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact retrievedContact = [SELECT Id, LastName FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        retrievedContact.LastName = newLastName;
        // Update the Contact in the database
        update retrievedContact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity retrievedOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        retrievedOpportunity.StageName = newStage;
        // Update the Opportunity in the database
        update retrievedOpportunity;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account retrievedAccount = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId];
        // Update the account's name and industry
        retrievedAccount.Name = newName;
        retrievedAccount.Industry = newIndustry;
        // Update the Account in the database
        update retrievedAccount;
        // Update the Account with the given Id with the new name and industry
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (Opportunity opp : opportunities) {
             opp.StageName = 'Qualification';
             opp.CloseDate = Date.today().addMonths(3);
             opp.Amount = 50000;
        }
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;     
    }
    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Get or create the Account once (avoids SOQL inside the loop)
        Account account = upsertAccount(accountName);

        // Query existing Opportunities by name to avoid duplicates
        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames AND AccountId = :account.Id];
        Map<String, Opportunity> existingOppsByName = new Map<String, Opportunity>();
        for (Opportunity existing : existingOpps) {
            existingOppsByName.put(existing.Name, existing);
        }

        // Loop through each Opportunity name
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
        for (String oppName : oppNames) {
            // Reuse existing record (has Id = update) or create new (no Id = insert)
            Opportunity opp = existingOppsByName.containsKey(oppName) ? existingOppsByName.get(oppName) : new Opportunity();
            opp.Name = oppName;
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
            opp.AccountId = account.Id;
            oppsToUpsert.add(opp);
        }
        // Upsert the list of Opportunities so that records are either updated or created
        upsert oppsToUpsert;
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		// if the Account exists, update the description
        if (!accounts.isEmpty()) {
            Account existingAccount = accounts[0];
            existingAccount.Description = 'Updated Account';
            update existingAccount;
            return existingAccount;
        }
		// otherwise, create a new Account and set the description

		Account newAccount2 = new Account();
        newAccount2.Name = accountName;
        newAccount2.Description = 'New Account';
        insert newAccount2;
		return newAccount2;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        for (Contact contact : contactsToUpsert) {
            // Extract the Account Name from Contact's LastName
            String accountName = contact.LastName;
            // Get the account based on the name or create one if it doesn't exist
            Account account = upsertAccount(accountName);
            // Link the Contact to its Account using the Account Id
            contact.AccountId = account.Id;
        }
         // Upsert the Contacts so that records are either updated or created
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> leadsToInsert = new List<Lead>();
        for (String leadName : leadNames) {
            Lead newLead = new Lead();
            newLead.LastName = leadName;
            newLead.Company = 'Unknown';
            leadsToInsert.add(newLead);
        }
        // Insert the Leads
        insert leadsToInsert;
        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case();
            newCase.AccountId = accountId;
            newCase.Subject = 'Test Case ' + i;
            casesToInsert.add(newCase);
        }
        insert casesToInsert;
        delete casesToInsert;
    }
}