/**
 * Created by wnardo on 8/2/2022.
 * Test: TEST_PaginatedController
 */

public abstract inherited sharing class PaginatedDAO {

	private static final String STR_WHERE = ' WHERE ';

	public abstract String getObjectName();

	public abstract List<String> getFields();

	public List<SObject> query(Criteria criteria){
		System.debug('PaginatedDAO::query::criteria ' + JSON.serialize(criteria));
		String query = 'SELECT ' + String.join(getFields(), ',')
			+ ' FROM ' + getObjectName()
			+ getWhere(criteria) + ' ORDER BY LastModifiedDate DESC '
			+ getPagination(criteria);

		System.debug('PaginatedDAO::query::' + query);
		return Database.query(query);
	}

	public Integer countQuery(Criteria crit){
		System.debug('PaginatedDAO::countQuery::criteria ' + JSON.serialize(crit));
		String query = 'SELECT COUNT(Id) FROM ' + getObjectName() + getWhere(crit);
		System.debug('PaginatedDAO::countQuery::' + query);
		List<AggregateResult> ar = Database.query(query);
		if (ar.isEmpty()) {
			return 0;
		}
		return Integer.valueOf(ar.get(0).get('expr0'));
	}

	private String getPagination(Criteria criteria){
		Integer limitQ = Integer.valueOf(criteria.resultNum);
		Integer pageNumQ = Integer.valueOf(criteria.pageNum);
		Integer offsetQ = limitQ * (pageNumQ - 1);
		return ' LIMIT ' + limitQ + ' OFFSET ' + offsetQ;
	}

	private String getWhere(Criteria criteria){
		String cond = STR_WHERE;
		if(String.isNotBlank(criteria.whereCondition)){
			cond += criteria.whereCondition;
		}

		return STR_WHERE.equals(cond) ? '' : cond;
	}

	public class Criteria {
		@AuraEnabled public String resultNum;
		@AuraEnabled public String pageNum;

		@AuraEnabled public String whereCondition;
	}
}