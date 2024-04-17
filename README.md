# SOQL Paginated Component

<a href="https://githubsfdeploy.herokuapp.com?owner=iNardex&repo=soql-paginated-component&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Quick Lookup | SOQL Data Viewer | Introduzione
---------------

![Demo Screenshot](https://github.com/iNardex/paginated-component/blob/main/images/example.png)

This is a Salesforce component that can be used to tabulate data retrieved from a query. Thanks to its versatility, it can be utilized to create dynamic tables, allowing for pagination of query results, sorting data based on specific criteria, and filtering data instantly through a full-text search field. Completely configurable via "Lightning App Builder" or "Flow," it does not require additional development.

-------------------

Si tratta di un componente Salesforce che può essere utilizzato per tabellare i dati presi da una query.
Grazie alla sua versatilità, è possibile utilizzarlo per creare tabelle dinamiche, che permettono di paginare i risultati di una query, ordinare i dati in base a specifici criteri e filtrare i dati in modo immediato, grazie ad un campo di ricerca full text.
Completamente configurabile da «Lightining App Builder» o «Flow» non richiede sviluppi aggiuntivi.


Usage / Utilizzo
-------------

To use the Paginated Component, simply drag it onto your Salesforce page from the custom components section. Once added, you can access the configuration panel (shown in the image on the left) to customize its settings.

Among the available configuration options, you can define the component title, the Object API Name for the object to be searched, the Object Fields (fields to display) separated by commas, as well as the number of results per page (Rows per page). Additionally, you can select an icon to use to the left of the title, enable the display of the button to delete a record (Show delete button), and activate the attachment download feature (Show download button).

By configuring the Click on name redirect, you can make the object name clickable, similar to other tables in Salesforce. Furthermore, you can construct the WHERE statement through the Where condition option, inserting expressions such as Name LIKE 'Edge%' or ParentId = '{recordId}'.

Lastly, the Order By field allows you to specify the field on which to order the results.

----------------------------

Per utilizzare il componente Paginated Component, basta trascinarlo nella propria pagina Salesforce dalla sezione dei componenti personalizzati. Una volta aggiunto, è possibile accedere al pannello di configurazione (mostrato nell'immagine a sinistra) per personalizzarne le impostazioni.

Tra le opzioni di configurazione disponibili, è possibile definire il titolo del componente, l'API Name dell'oggetto da ricercare, i campi dell'oggetto da visualizzare (Object Fields) separati da virgola e il numero di risultati per pagina (Row per page). È inoltre possibile selezionare un'icona da posizionare a sinistra del titolo, abilitare la visualizzazione del pulsante per eliminare un record (Mostra pulsante di eliminazione) e attivare la funzionalità di download degli allegati (Mostra pulsante di download).

Grazie alla configurazione di Click on name redirect, è possibile rendere il nome dell'oggetto cliccabile, come avviene per le altre tabelle presenti in Salesforce. Inoltre, è possibile costruire la clausola WHERE attraverso l'opzione Where condition, inserendo ad esempio espressioni come Name LIKE 'Edge%' o ParentId = ‘{recordId}’.

Infine, il campo Order By permette di specificare il campo su cui ordinare i risultati.

