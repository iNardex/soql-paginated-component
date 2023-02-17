/**
 * Created by wnardo on 8/2/2022.
 * Test: TEST_PaginatedController
 */

public with sharing class PaginatedController {

	public static final Map<String, String> mapFieldType = new Map<String, String>{
			'BOOLEAN' => 'boolean',
			'CURRENCY' => 'currency',
			'DATE' => 'date',
			'DATETIME' => 'date',
			'EMAIL' => 'email',
			'DOUBLE' => 'number',
			'PICKLIST' => 'text',
			'INTEGER' => 'number',
			'MULTIPICKLIST' => 'text',
			'PERCENT' => 'percent',
			'PHONE' => 'phone',
			'REFERENCE' => 'text',
			'STRING' => 'text',
			'TEXTAREA' => 'text',
			'URL' => 'url'
	};

	@AuraEnabled(Cacheable = true)
	public static Map<String, ColumnWrapper> retrieveObjectLabel(String objectName){

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = schemaMap.get(objectName);
		Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();

		Map<String, ColumnWrapper> columnsWrapper = new Map<String, ColumnWrapper>();
		for (String fieldName: fieldMap.keySet()) {
			ColumnWrapper wrapper = new ColumnWrapper(
					fieldName,
					fieldMap.get(fieldName).getDescribe().getLabel(),
					parseTypeField(fieldMap.get(fieldName).getDescribe().getType().name()),
					fieldMap.get(fieldName).getDescribe().isSortable()
			);
			columnsWrapper.put(fieldName, wrapper);
		}

		return columnsWrapper;
	}

	@AuraEnabled
	public static DataWrapper retrievePaginatedResult(String objectName, List<String> fields, String criteriaJson){
		System.debug('PaginatedController::retrievePaginatedResult::objectName ' + objectName );
		System.debug('PaginatedController::retrievePaginatedResult::fields ' + JSON.serialize(fields) );
		System.debug('PaginatedController::retrievePaginatedResult::criteriaJson ' + criteriaJson );

		PaginatedDAO.Criteria criteria = (PaginatedDAO.Criteria) JSON.deserialize(criteriaJson, PaginatedDAO.Criteria.class);
		final GenericDAO dao = new GenericDAO(objectName, fields);
		DataWrapper toRet = new DataWrapper(dao.query(criteria), dao.count(criteria));

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

	public static String parseTypeField(String type) {
		return mapFieldType.get(type) != null ? mapFieldType.get(type) : 'string';
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

	public class DataWrapper {

		public DataWrapper(List<SObject> data, Integer resultNum){
			this.data = data;
			this.resultNum = resultNum;
		}

		@AuraEnabled public List<SObject> data;
		@AuraEnabled public Integer resultNum;
	}

	public class ColumnWrapper {

		public ColumnWrapper(String apiName, String label, String type, Boolean isSortable){
			this.apiName = apiName;
			this.label = label;
			this.type = type;
			this.isSortable = isSortable;
		}

		@AuraEnabled public String apiName;
		@AuraEnabled public String label;
		@AuraEnabled public String type;
		@AuraEnabled public Boolean isSortable;
	}

}