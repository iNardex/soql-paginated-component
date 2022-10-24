public abstract class PaginatedDAO {

	private static final String STR_WHERE = ' WHERE ';
	private static final String ORDER_BY = ' ORDER BY ';
	private static final String NULLS_LAST = ' NULLS LAST ';

	public abstract String getObjectName();

	public abstract List<String> getFields();

	public List<SObject> query (Criteria criteria){
		System.debug('PaginatedDAO::query::criteria ' + JSON.serialize(criteria));
		if (String.isNotBlank(criteria.inputSearch)) {
			return soslQuery(criteria);
		} else {
			return soqlQuery(criteria);
		}
	}
	public List<SObject> soqlQuery(Criteria criteria){
		String query = 'SELECT ' + String.join(getFields(), ',')
				+ ' FROM ' + getObjectName()
				+ getWhere(criteria)
				+ getOrderBy(criteria)
				+ getPagination(criteria);

		System.debug('PaginatedDAO::soqlQuery::' + query);
		return Database.query(query);
	}

	public List<SObject> soslQuery(Criteria criteria){
		String query = 'FIND \'' + criteria.inputSearch + '\' IN ALL FIELDS RETURNING '
				+ getObjectName() + '(' + String.join(getFields(), ',')
				+ getWhere(criteria)
				+ getOrderBy(criteria)
				+ getPagination(criteria)
				+ ')';

		System.debug('PaginatedDAO::soslQuery::' + query);
		List<List<SObject>> sObjects = Search.query(query);
		return sObjects.get(0);
	}

	public Integer count(Criteria criteria){
		System.debug('PaginatedDAO::count::criteria ' + JSON.serialize(criteria));
		if (String.isNotBlank(criteria.inputSearch)) {
			return countSoslQuery(criteria);
		} else {
			return countSoqlQuery(criteria);
		}
	}

	public Integer countSoqlQuery(Criteria crit){
		String query = 'SELECT COUNT(Id) FROM ' + getObjectName() + getWhere(crit);
		System.debug('PaginatedDAO::countSoqlQuery::' + query);
		List<AggregateResult> ar = Database.query(query);
		if (ar.isEmpty()) {
			return 0;
		}
		return Integer.valueOf(ar.get(0).get('expr0'));
	}

	public Integer countSoslQuery(Criteria criteria) {
		String query = 'FIND \'' + criteria.inputSearch + '\' IN ALL FIELDS RETURNING '
				+ getObjectName() + '(' + String.join(getFields(), ',') + getWhere(criteria) + ')';

		System.debug('PaginatedDAO::countSoslQuery::' + query);
		List<List<SObject>> sObjects = Search.query(query);
		return sObjects.get(0).size();
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

	private String getOrderBy(Criteria criteria){
		String order = ORDER_BY;
		if (String.isNotBlank(criteria.orderBy)) {
			order += criteria.orderBy + NULLS_LAST;
		}

		return ORDER_BY.equals(order) ? '' : order;
	}

	public class Criteria {
		@AuraEnabled public String resultNum;
		@AuraEnabled public String pageNum;

		@AuraEnabled public String inputSearch;
		@AuraEnabled public String whereCondition;
		@AuraEnabled public String orderBy;
	}
}