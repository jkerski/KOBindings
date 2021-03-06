﻿/*
	Requires SPServices, init.js, core.js, and jQuery
*/
ko.bindingHandlers.spPeoplePicker = {
    init: function(element, valueAccessor, allBindingsAccessor) {
            // Initially set the element to be instantly visible/hidden depending on the value
            var value = valueAccessor();

            //Parameter trigger provides dom element that initaties show or hide
            var valueUnwrapped = ko.unwrap(value);

            //Click
            $(element).click(function() {
                var dialogPromise = $.Deferred(function(dfd) {
                    var searchString = "";
                    var dialogOptions = 'resizable:yes; status:no; scroll:no; help:no; center:yes; dialogWidth :575px; dialogHeight :500px;';
                    var dialogURL = $().SPServices.SPGetCurrentSite() + '/_layouts/picker.aspx';

                    dialogURL += '?MultiSelect=False';
                    dialogURL += '&CustomProperty=User,SecGroup,SPGroup;;15;;;False';
                    dialogURL += '&EntitySeparator=;';
                    dialogURL += '&DialogTitle=Select People and Groups';
                    dialogURL += '&DialogImage=/_layouts/images/ppeople.gif';
                    dialogURL += '&PickerDialogType=Microsoft.SharePoint.WebControls.PeoplePickerDialog, Microsoft.SharePoint, Version=12.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c';
                    dialogURL += '&DefaultSearch=' + escapeProperly(searchString);

                    //Call Dialog
                    dialogHandle = commonShowModalDialog(dialogURL, dialogOptions, function(searchResult) {

                        var xmlDoc = $.parseXML(searchResult);
                        var $xml = $(xmlDoc);
                        //Get User ID
                        var fqn = $xml.find('Entity').attr('Key');
                        //Get Display Text
                        var dispText = $xml.find('Entity').attr('DisplayText');
                        //Get SharePoint ID
                        var sharePointID = $xml.find('Value:first').text();
                        //Resolve deferred object
                        //Save this information
                        var xData = {
                                loginName: fqn,
                                userName: dispText,
                                userId: ''
                            } //end call dialog 

                        //Resolve
                        dfd.resolve(xData);
                    }); //End callback
                }).promise(); //End promise

                //End dialog
                dialogPromise.done(function(userData) {
                    $().SPServices({
                        operation: "ResolvePrincipals",
                        principalKeys: "<string>" + userData.loginName + "</string>",
                        addToUserInfoList: true
                    }).done(function(xData) {
                        //Get User Id
                        userData.userId = jQuery(xData).SPFilterNode("UserInfoID").text();

                        //Set Observable
                        value(userData);

                    }); //end done
                }); //end resultPromise


            }); //end click

        } //end init
};