import { LightningElement, api } from 'lwc';
import retrievePaginatedResult from '@salesforce/apex/PaginatedController.retrievePaginatedResult';
import getUser from '@salesforce/apex/PaginatedController.getUser';
import getAccount from '@salesforce/apex/PaginatedController.getAccount';
import deleteItem from '@salesforce/apex/PaginatedController.deleteItem';
import retrieveObjectLabel from '@salesforce/apex/PaginatedController.retrieveObjectLabel';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const ISO_DATE_REGEXP = /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?$/;
const ACTIONS =  { label: 'Delete', name: 'delete' };

const RECORD_STR = "{recordId}";
const USER_ID = "{userId}";

export default class PaginatedComponent extends NavigationMixin(LightningElement) {

    @api title;
    @api objectName;
    @api fields;
    @api row;
    @api deleteEnabled;
    @api cardIcon;
    @api nameAsLink;
    @api whereCondition;
    @api recordId;

    fieldsDefinition = [];

    currentUser;
    currentAccount;
    isLoading = true;
    isEmpty = false;
    tableData = [];

    columns = [];
    page = 1;
    countRow = 0;

    connectedCallback(){
        this.init();
        this.generateTableColumns();
    }

    async init(){
        this.currentUser = await getUser();
        console.log('user: ' + JSON.stringify(this.currentUser));
        this.currentAccount = await getAccount({accountId: this.currentUser.AccountId});
        console.log('account: ' + JSON.stringify(this.currentAccount));
        this.retrieveData();
    }

    async generateTableColumns(){
        const labelMap = await retrieveObjectLabel({objectName: this.objectName});
        this.fieldsDefinition = this.fields.split(',').map(f=>f.trim());
        this.columns = this.fieldsDefinition.map(f=>{
            const def = {
                label: this.optimizeName(f, labelMap),
                fieldName: f,
                hideDefaultActions: true
            }

            if(this.nameAsLink && f.toUpperCase().endsWith('NAME')){
               def.fieldName = f.toUpperCase() === 'NAME' ? 'URL' : f.toUpperCase().replace('.NAME', '.URL');
                def.type = 'url';
                def.typeAttributes = {
                    label: {
                        fieldName: f
                    }
                }
            }

            return def;
        });
        let actions = {
            type: 'action',
            typeAttributes: { rowActions: [] }
        }

        if(this.deleteEnabled){
            actions.typeAttributes.rowActions.push(ACTIONS);
        }


        if (actions.typeAttributes.rowActions.length > 0) {
            this.columns.push(actions);
        }
    }

    optimizeName(name, labelMap) {
        return labelMap[name.toLowerCase()] ?? name.replace('__c', '').replace('__r.', ' ');
    }

    parseWhereCondition(){
        return (this.whereCondition ?? '')
        .replace(RECORD_STR, this.recordId)
        .replace(USER_ID, this.currentUser.Id);
    }

    retrieveData(){
        this.isLoading = true;
        const criteria = {
            resultNum: this.row,
            pageNum: this.page,
            whereCondition: this.parseWhereCondition()
        };

        retrievePaginatedResult({objectName: this.objectName, fields: this.fieldsDefinition, criteriaJson: JSON.stringify(criteria) })
        .then(result =>{
           this.manageRetrieveData(result);
        }).catch(error => {
           console.log('error ' + JSON.stringify(error));
           this.isLoading = false;
        });
    }
    
    async manageRetrieveData(result){
        let data = [...result.data];
        data = this.flatExternalObj(data);
        for(let row of data){
            let idsProp = Object.getOwnPropertyNames(row).filter(prop => prop.toUpperCase().endsWith('ID'));
            for(let prop of idsProp){
                 let objectName = this.objectName;
                 if(prop.indexOf('__r' ) !== -1 ){
                     objectName = prop.toUpperCase().replace('.ID', '').replace('__R', '__C');
                 }
                 const result = await this[NavigationMixin.GenerateUrl]({
                     type: "standard__recordPage",
                     attributes: {
                         recordId: row[prop],
                         objectApiName: objectName,
                         actionName: "view"
                     }
                 });
        
                 const key = prop.toUpperCase() === 'ID' ? 'URL' : prop.toUpperCase().replace('.ID', '.URL');
                 row[key] = result;
            }

             Object.getOwnPropertyNames(row)
             .filter(prop => ISO_DATE_REGEXP.test(row[prop]))
             .forEach(prop => {
				row[prop] = new Date(Date.parse(row[prop])).toLocaleString();
             });
        }
        
        this.tableData = [...data];
        this.isEmpty = result.resultNum === 0;
        this.countRow = result.resultNum
        this.isLoading = false;
    }

    flatExternalObj(data){
        return data.map(row => {
            Object.getOwnPropertyNames(row)
            .filter(prop => prop.indexOf('__r') !== -1)
            .map(prop => {
                let mapped = {};
                Object.getOwnPropertyNames(row[prop]).forEach(internalProp => mapped[prop + '.' + internalProp] = row[prop][internalProp]);
                return mapped;
            })
            .forEach(mapped=>{
               row = {
                   ...mapped,
                   ...row
               };
            });
            return row;
        });
    }

    handlePrev(event) {
        this.page--;
        this.retrieveData();
    }

    handleNext(event) {
        this.page++;
        this.retrieveData();
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    deleteRow(row){
        this.isLoading = true;
        deleteItem({id: row.Id})
        .then(result => {
            const title = this.titleText + ' "' + row.Name + '" was deleted' ;
            const evt = new ShowToastEvent({
                title: title,
                variant: 'success',
            });
            this.dispatchEvent(evt);
            eval("$A.get('e.force:refreshView').fire();");
            this.retrieveData();
        })
        .catch(error=>{

        });
    }

    get disablePrevButton() {
       return this.page === 1;
    }

    get disableNextButton(){
       if(!this.countRow || this.countRow === 0)
            return true;
       return this.page * Number(this.row) >= this.countRow;
    }

    get titleText(){
        return this.title ?? this.optimizeName(this.objectName);
    }

}