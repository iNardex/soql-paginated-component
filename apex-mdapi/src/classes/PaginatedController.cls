/**
 * Created by wnardo on 8/2/2022.
 * Test: TEST_PaginatedController
 */

public with sharing class PaginatedController {

	@AuraEnabled(Cacheable = true)
	public static Map<String, String> retrieveObjectLabel(String objectName){

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(objectName);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

		Map<String, String> fieldLabelMap = new Map<String, String>();
		for (String fieldName: fieldMap.keySet()) {
			fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
		}

		return fieldLabelMap;
	}

	@AuraEnabled
	public static GenericWrapper retrievePaginatedResult(String objectName, List<String> fields, String criteriaJson){
		System.debug('PaginatedController::retrievePaginatedResult::objectName ' + objectName );
		System.debug('PaginatedController::retrievePaginatedResult::fields ' + JSON.serialize(fields) );
		System.debug('PaginatedController::retrievePaginatedResult::criteriaJson ' + criteriaJson );

		PaginatedDAO.Criteria criteria = (PaginatedDAO.Criteria) JSON.deserialize(criteriaJson, PaginatedDAO.Criteria.class);
		final GenericDAO dao = new GenericDAO(objectName, fields);
		GenericWrapper toRet = new GenericWrapper(dao.query(criteria), dao.countQuery(criteria));

		System.debug('PaginatedController::retrievePaginatedResult::return ' + JSON.serialize(toRet));
		return toRet;
	}

	@AuraEnabled
	public static User getUser(){
		return [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
	}

	@AuraEnabled
	public static Account getAccount(Id accountId){
		try {
			return [SELECT Id FROM Account WHERE Id =: accountId];
		} catch (Exception e) {
			return null;
		}
	}

	@AuraEnabled
	public static void deleteItem(String id){
		System.debug('PaginatedController::deleteItem::id ' + id );
		Database.delete(id);
		System.debug('PaginatedController::deleted::id ' + id );
	}

	public class GenericDAO extends PaginatedDAO {

		private final String objectName;
		private final List<String> fields;

		public GenericDAO(String objectName, List<String> fields) {
			this.objectName = objectName;
			this.fields = cleanFields(fields);
		}

		public override String getObjectName() {
			return this.objectName;
		}

		public override List<String> getFields() {
			return this.fields;
		}

		private List<String> cleanFields(List<String> fields){
			Set<String> setFields = new Set<String>();
			for(String f : fields){
				setFields.add(f.toUpperCase());
			}
			setFields.add('ID');
			return new List<String>(setFields);
		}
	}

	public class GenericWrapper {

		public GenericWrapper(List<SObject> data, Integer resultNum){
			this.data = data;
			this.resultNum = resultNum;
		}

		@AuraEnabled public List<SObject> data;
		@AuraEnabled public Integer resultNum;
	}

}