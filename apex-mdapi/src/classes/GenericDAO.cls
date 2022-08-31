/**
 * Created by wnardo on 2/28/2022.
 * Test Class : DAOTest
 */

public class GenericDAO {

    public static List<ProcessInstance> retrieveProcessInstancePendingByObjIds(List<String> objectIds){
        final String query = 'SELECT Id FROM ProcessInstance ' +
                'WHERE Status = \'Pending\' AND TargetObjectId IN :objectIds';
        System.debug('GenericDAO::retrieveProcessInstancePendingByTargetIds::query: ' + query);
        return Database.query(query);
    }

    public static List<ProcessInstanceWorkitem> retrieveWorkItemByInstanceIds(List<String> processInstanceIds){
        final String query = 'SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :processInstanceIds';
        System.debug('GenericDAO::retrieveWorkItemByInstanceIds::query: ' + query);
        return Database.query(query);
    }

    public static PermissionSet retrievePermissionSetByName(String name){
        try{
            final String query = 'SELECT Id FROM PermissionSet WHERE Name = :name LIMIT 1';
            System.debug('GenericDAO::retrievePermissionSetByName::query: ' + query);
            return Database.query(query);
        } catch (Exception e){
            return null;
        }
    }

    public static List<PermissionSetAssignment> retrievePermissionSetAss(List<String> userIds, String permissionId){
        try{
            final String query = 'SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userIds AND PermissionSetId = :permissionId ';
            System.debug('GenericDAO::retrievePermissionSetAss::query: ' + query);
            return Database.query(query);
        } catch (Exception e){
            return null;
        }
    }

    public static List<ContentDocumentLink> retrieveContentDocumentLinks(List<String> linkedEntityIds){
        if(linkedEntityIds == null || linkedEntityIds.isEmpty()){
            return new List<ContentDocumentLink>();
        }
        final String query = 'SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds';
        System.debug('GenericDAO::retrieveContentDocumentLinks::query: ' + query);
        return Database.query(query);
    }

    public static List<ContentVersion> retrieveContentVersions(List<String> docIds){
        final String query = 'SELECT Id, PathOnClient, Title, VersionData, ContentDocumentId ' +
                'FROM ContentVersion WHERE ContentDocumentId IN :docIds';
        System.debug('GenericDAO::retrieveContentVersions::query: ' + query);
        return Database.query(query);
    }

}