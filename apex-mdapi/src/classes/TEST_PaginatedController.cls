@IsTest
private class TEST_PaginatedController {

	@IsTest
	static void testBehavior() {
		User usr = [SELECT Id, AccountId FROM User LIMIT 1];

		PaginatedDAO.Criteria crit = new PaginatedDAO.Criteria();
		crit.pageNum = '1';
		crit.resultNum = '1';
		crit.whereCondition = 'Id = \'' + usr.Id + '\'';

		PaginatedController.retrievePaginatedResult('User', new List<String>{'Id','Name'}, JSON.serialize(crit));
		PaginatedController.retrieveObjectLabel('Account');
		PaginatedController.getAccount(usr.AccountId);
	}

	@IsTest
	static void testSosl() {
		User usr = [SELECT Id, AccountId FROM User LIMIT 1];

		PaginatedDAO.Criteria crit = new PaginatedDAO.Criteria();
		crit.pageNum = '1';
		crit.resultNum = '1';
		crit.whereCondition = 'Id = \'' + usr.Id + '\'';
		crit.inputSearch = 'Pippo';

		PaginatedController.retrievePaginatedResult('User', new List<String>{'Id','Name'}, JSON.serialize(crit));
		PaginatedController.retrieveObjectLabel('Account');
		PaginatedController.getAccount(usr.AccountId);
	}
}
