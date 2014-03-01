<cfimport taglib="pagelets" prefix="mail">
<cfset udf = request.udf>

<!--- Create an array. --->

<!--- Use the array to add a column to the query. --->
<cfif structkeyexists(url, 'action')>
	<cfswitch expression="#url.action#">
		<cfcase value="list">
			<cfscript>
				startRow = udf.getStartRow(url);
				maxrows = udf.getMaxRows(url);
				qryMail = udf.getMails(startRow, maxrows);
				writeOutput(serializeJSON(qryMail));
			</cfscript>
		</cfcase>
		<cfcase value="show">
			<cfoutput>
				<mail:body mail="#urlDecode(url.mail)#">
			</cfoutput>
		</cfcase>
		<cfcase value="deleteEmail">
			<cftry>
				<cffile action="delete" file="#application.maildir#/#URLDecode(url.mail)#"> ok
			<cfcatch type = "any">fail</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="deleteList">
			<cftry>
				<cfloop list="#lstMail#" index="name">
					<cffile action="delete" file="#application.maildir#/#URLDecode(name)#">
				</cfloop>ok
			<cfcatch type = "any">fail</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="deleteAll">
			<cftry>
				<cfdirectory action="list" directory="#application.maildir#" recurse="true" listinfo="name" name="qFile" />
				<cfloop query="qFile">
					<cffile action="delete" file="#application.maildir#/#name#">
				</cfloop>ok
			<cfcatch type = "any">fail</cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="nextPage">
			<cfset qryMail = udf.getMailList()>
			<cfset toTalPage = ceiling(qryMail.recordCount / session.perPage)>
			<cfif session.currentPage lt toTalPage>
				<cfset session.currentPage += 1>
			</cfif>
			<mail:list qrymail="#qryMail#">
		</cfcase>
		<cfcase value="prevPage">
			<cfset qryMail = request.udf.getMailList()>
			<cfif session.currentPage gt 1>
				<cfset session.currentPage -= 1>
			</cfif>
			<mail:list qrymail="#qryMail#">
		</cfcase>
		<cfcase value="updatePerpage">
			<cfset session.perPage = url.perPage>
			<cfset session.currentPage = 1>
			<cfset qryMail = request.udf.getMailList()>
			<mail:list qrymail="#qryMail#">
		</cfcase>
		<cfdefaultcase>
			<h2 class="page-header">Invalid!</h2>
			<cfabort>
		</cfdefaultcase>
	</cfswitch>
</cfif>