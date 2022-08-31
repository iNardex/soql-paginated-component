/**
 * Created by wnardo on 8/2/2022.
 */

@IsTest
public class TEST_PaginatedController {

	@IsTest(SeeAllData=true)
	public static void testController() {
		User usr = [SELECT Id FROM User LIMIT 1];

		PaginatedDAO.Criteria crit = new PaginatedDAO.Criteria();
		crit.pageNum = '1';
		crit.resultNum = '1';
		crit.whereCondition = 'Id = \'' + usr.Id + '\'';

		Map<String, String> labelMap = PaginatedController.retrieveObjectLabel('User');
		System.assert(!labelMap.isEmpty());
		PaginatedController.retrievePaginatedResult('User', new List<String>{'Id','Name'}, JSON.serialize(crit));

		User u = PaginatedController.getUser();
		System.assertEquals(UserInfo.getUserId(), u.Id);

		PaginatedController.getAccount([SELECT Id FROM Account LIMIT 1].Id);
	}


}