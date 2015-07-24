<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta name="WebPartPageExpansion" content="full" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled 1</title>
</head>

<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" media="all"/>
<style>
	.search-results{
		height:300px;
		overflow-y:auto
	}
</style>
<body>
<div class="container">
	<div class="row">
		<div class="col-sm-12">
			<form class="form-inline">
			  <div class="form-group">
			    <label class="control-label" for="search">Find</label>
			    <div class="input-group">
			      <input type="text" class="form-control" id="search" placeholder="Search..." data-bind="textInput: searchFilter"/>
			    </div>
			  </div>
				<button class="btn btn-default" data-bind="click: search">
					<span class="glyphicon glyphicon-search"> Search</span>
				</button>
			</form>
		</div><!--End Column-->
	</div><!--End Row-->	
	<div class="row search-results">
		<div class="col-sm-12">
			<table id="searchResults" summary="Search Results" class="table table-bordered table-condensed" aria-live="polite">
				<thead>
					<tr>
						<th scope="col">Display Name</th>
						<th scope="col">Title</th>
						<th scope="col">Department</th>
						<th scope="col">E-Mail</th>
						<th scope="col">Account Name</th>
					</tr>
					<tr data-bind="visible: isNoResults">
						<td colspan="5" class="text-center">
							<em>No Results Found</em>
						</td>
					</tr>
				</thead>
				<tbody data-bind="foreach: searchResults"  >
					<tr data-bind="css: rowCSS, click: function(data, event) { $root.principalClicked($index, data, event); }">
						<td scope="row" data-bind="text: displayName"></td>
						<td data-bind="text: title"></td>
						<td data-bind="text: department"></td>
						<td data-bind="text: email"></td>
						<td data-bind="text: accountName"></td>
					</tr>
				</tbody>
			</table>		
		</div><!--End Column-->
	</div><!--End Row-->
</div><!-- End Container-->
</body>
<script src="https://code.jquery.com/jquery-1.11.3.min.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.SPServices/2014.02/jquery.SPServices-2014.02.min.js" type="text/javascript"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.3.0/knockout-debug.js" type="text/javascript"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" type="text/javascript"></script>
<script>

	   /*@Object Principal - Represents a user from a search result*/	
	   var PrincipalViewModel = function(data){
	   		/*@variable reference to this*/
	   		var self = this;
	   		
	   		/*@property Account Name*/
	   		self.accountName = ko.observable(data.accountName);
	   		
	   		/*@property Department*/
	   		self.department = ko.observable(data.department);

			/*@property Email*/
	   		self.email = ko.observable(data.email);
	   		
	   		/*@property Is Resolved*/
	   		self.isResolved = ko.observable(data.isResolved);
	   		
	   		/*@property Principal Type*/
	   		self.principalType = ko.observable(data.principalType);
	   		
	   		/*@property Title*/
	   		self.title = ko.observable(data.title);
	   		
	   		/*@property User Info ID*/
	   		self.userInfoID = ko.observable(data.userInfoID);
	   		
	   		/*@property Display Name*/
	   		self.displayName = ko.observable(data.displayName);
	   		
	  		////// Row Selection   //////
	  		
	  		/*@property Bootstrap CSS class*/
	   		self.selectedCSS = "bg-primary";
	   		
	   		/*@property Row CSS*/
	   		self.rowCSS = ko.observable("");
	   		
	   		/*@property is selected*/
	   		self.isSelected = ko.observable(false);
	
			/*@function Handle change is CSS*/
			self.isSelected.subscribe(function(){
				if(self.isSelected() === true){
					self.rowCSS(self.selectedCSS);				
				}else{
					self.rowCSS('');				
				}//end if
			});
	
			/*@function toggle select*/
	   		self.toggleSelect = function(){
				if(self.isSelected() === true)
				{
					self.isSelected(false);
				}
				else
				{
					self.isSelected(true);
				}   
	   		};//end toggle Selected
	   		   		
	   };//end Principal
   
   	   /*@Object View Model for Search*/
	   var PrincipalSearchViewModel = function(isMultiUser){
	   		/*@variable reference to this*/
	   		var self = this;
	   		
	   		/*@array Search Results*/
	   		self.searchResults = ko.observableArray();
	   		
	   		/*@property Search Filter*/
	   		self.searchFilter = ko.observable('');
	   		
	   		/*@property Identifies if multiple users can be selected*/
	   		self.isMultiUser = ko.observable(isMultiUser === true ? true : false);
	
			/*@function Row Clicked*/
	   		self.principalClicked = function(index){
	   			
	   			var index = index();
	   
				self.searchResults()[index].toggleSelect();
							   			
	   			if(self.isMultiUser() === false){
	   				for(var i = 0; i < self.searchResults().length; i++)
	   				{
	   					if(i !== index){
	   						self.searchResults()[i].isSelected(false);
	   					}
	   				}//end for loop
	   			}//end if
	   		};//end principalClicked
	   		
	   		/*@propety Handle if no results were found*/
	   		self.isNoResults = ko.observable(false);
	   		
	   		/*@function Search via People.asmx*/
	   		self.search = function(){
	   		
				$().SPServices({
					  operation: "SearchPrincipals",
					  webURL: "/",
					  searchText: self.searchFilter(),
					  maxResults: 100,
					  SPPrincipalType: "SPPrincipalType.User",
					  completefunc: function (xData, Status) {
						var resultsArray = [];
						$(xData.responseXML).SPFilterNode("PrincipalInfo").each(function() {
						var info = {};
						info.accountName = $(this).find('AccountName').text();
						info.userInfoID = $(this).find('UserInfoID').text();
						info.displayName = $(this).find('DisplayName').text();
						info.email = $(this).find('Email').text();
						info.department = $(this).find('Department').text();
						info.title = $(this).find('Title').text();
						info.isResolved = $(this).find('IsResolved').text();
						info.principalType = $(this).find('PrincipalType').text();
						  //Principal
						  resultsArray.push(new PrincipalViewModel(info));
					  });//end for each
					  self.searchResults(resultsArray);
					  
					  if(resultsArray.length == 0)
					  {
					  	self.isNoResults(true);
					  }
					  else{
					  	self.isNoResults(false);
					  }
					  
			  		}//end completefunc
			  });//end SP services		   		
	   		
	   		};//end search
	   };//end PrincipalSearchViewModel

	//Document Ready
	$(document).ready(function(){
		//Apply Bindings
		ko.applyBindings(new PrincipalSearchViewModel(false));
	});//end document.ready
</script>
</html>
