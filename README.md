# SOQL Paginated Component

<a href="https://githubsfdeploy.herokuapp.com?owner=iNardex&repo=soql-paginated-component&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Quick Lookup | SOQL Data Viewer | Introduzione
---------------

![Demo Screenshot](https://github.com/iNardex/paginated-component/blob/main/images/example.png)

Si tratta di un componente Salesforce che può essere utilizzato per tabellare i dati presi da una query.
Grazie alla sua versatilità, è possibile utilizzarlo per creare tabelle dinamiche, che permettono di paginare i risultati di una query, ordinare i dati in base a specifici criteri e filtrare i dati in modo immediato, grazie ad un campo di ricerca full text.
Completamente configurabile da «Lightining App Builder» o «Flow» non richiede sviluppi aggiuntivi.

Utilizzo
-------------
Per utilizzare il componente Paginated Component, è sufficiente trascinarlo nella propria pagina Salesforce dalla sezione dei componenti custom. Una volta inserito, è possibile accedere al pannello di configurazione (rappresentato nell'immagine a sinistra) per personalizzare le impostazioni del componente.

Tra le opzioni di configurazione disponibili, è possibile specificare il Titolo del componente, l'Object API Name per l'oggetto da ricercare, gli Object Fields (i campi da visualizzare) separati da virgola, nonché il numero di risultati per pagina (Row for page). Inoltre, è possibile selezionare un'icona da utilizzare a sinistra del titolo, abilitare la visualizzazione del bottone per eliminare un record (Show delete button) e attivare la funzionalità di download degli allegati (Show download button).

Grazie alla configurazione del Click on name redirect, sarà possibile rendere cliccabile il nome dell'oggetto, come avviene per le altre tabelle presenti in Salesforce. Inoltre, è possibile costruire lo statement di WHERE attraverso l'opzione Where condition, inserendo ad esempio espressioni come Name LIKE 'Edge%' oppure ParentId = ‘{recordId}’.
Infine, il campo Order By consente di specificare il campo su cui ordinare i risultati.

