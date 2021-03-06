qbPhone = {}

var inPhone = false;
var phoneApps = null;
var allowNotifys = null;
var myNotify = false;
var currentApp = ".phone-home-page";
var homePage = ".phone-home-page";
var lastPage = null;
var choosingBg = false;
var curBg = "bg-1";
var selectedContact = null;

var suggestedNumber = null;
var suggestedBank = null;

var currentChatNumber = null;

var myCitizenId = null;

var inCall = false;

var currentMailEvent = null;
var currentMailData = null;
var mailId = null;

var CurrentBankTab = "accounts"

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            qbPhone.Close();
            break;
        case 13:
            qbPhone.SendMessage();
            break;
    }
});

$(document).on('click', '.bank-app-header-tab', function(e){
    var PressedTab = $(this).data('tab');

    if (PressedTab !== CurrentBankTab) {
        $(".bank-"+CurrentBankTab+"-tab").css({"display":"none"});
        $(".bank-app-header").find('[data-tab="'+CurrentBankTab+'"]').removeClass('bank-header-selected');
        CurrentBankTab = PressedTab;
        $(".bank-app-header").find('[data-tab="'+CurrentBankTab+'"]').addClass('bank-header-selected');
        $(".bank-"+CurrentBankTab+"-tab").css({"display":"block"});
    }
});

$(document).on('click', '.companies-item', function(e){
    var maxRank = 6;
    var companyData = $(this).data('companyData');
    $(".companies-item").removeClass("companies-item-selected");
    $(this).addClass("companies-item-selected");
    $(".companies-buttons").html("");
    if (companyData.rank == maxRank) {
        var elem = '<div class="companies-settings-small-btn"><p>Management</p></div><div class="companies-quit-small-btn"><p>Verwijder</p></div>';
        $(".companies-buttons").html(elem);
        $(".companies-quit-small-btn").data("companyData", companyData)
        $(".companies-settings-small-btn").data("companyData", companyData)
    } else if (companyData.rank == (maxRank-1)) {
        var elem = '<div class="companies-settings-small-btn"><p>Instellingen</p></div><div class="companies-quit-btn"><p>Neem Ontslag</p></div>';
        $(".companies-buttons").html(elem);
        $(".companies-quit-btn").data("companyData", companyData)
        $(".companies-settings-small-btn").data("companyData", companyData)
    } else {
        var elem = '<div class="companies-quit-btn"><p>Neem Ontslag</p></div>';
        $(".companies-buttons").html(elem);
        $(".companies-quit-btn").data("companyData", companyData)
    }
});

$(document).on('click', '.employee-item', function(e){
    var maxRank = 6;
    //var companyData = $(this).data('companyData');
    $(".employee-item").removeClass("employee-item-selected");
    $(this).addClass("employee-item-selected");
    $(".employees-buttons").html("");
    var elem = '<div class="employee-pay-btn"><p>Betaal</p></div><div class="employee-alter-buttons"><div class="employee-promote-btn"><p>Promote</p></div><div class="employee-demote-btn"><p>Demote</p></div></div><div class="employee-quit-btn"><p>Ontslaan</p></div>';
    $(".employees-buttons").html(elem);
    //$(".companies-quit-btn").data("companyData", companyData)
    //$(".companies-settings-small-btn").data("companyData", companyData)
});

qbPhone.OpenPayPhone = function() {
    $(".payphone-input").text("");
    $(".payphone").fadeIn(150);
}

$(document).on('click', '.payphone-dial', function(e){
    var dialNumber = $(this).data('number');
    var NumberInput = $(".payphone-input");
    var CurNumber = $(".payphone-input").text();

    if (dialNumber == "remove") {
        NumberInput.text("");
    } else {
        NumberInput.text(CurNumber + dialNumber);
    }
});

$(document).on('click', '.payphone-call', function(e){
    var CurNumber = $(".payphone-input").text();
    
    if (CurNumber != "") {
        $.post('http://qb-phone/CallPayPhone', JSON.stringify({
            number: CurNumber
        }));
        $(".payphone").fadeOut(150);
    }
});

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();

    window.addEventListener('message', function(event){
        var eventData = event.data;

        if (eventData.action == "phone") {
            if (!eventData.task) {
                if (eventData.open == true) {
                    qbPhone.Open(eventData.cid)
                    qbPhone.setupPhoneApps(eventData.apps)
                } else if (eventData.open == false) {
                    qbPhone.Close()
                }
            }
        }

        if (eventData.task == "callScreen") {
            if (eventData.callData.inCall || eventData.callData.outgoingCall || eventData.callData.incomingCall) {
                qbPhone.CallScreen(event.data.callData)
            }
        }

        if (eventData.task == "setPhoneMeta") {
            qbPhone.setPhoneMeta(eventData.pMeta, eventData.pData.charinfo.phone);
        }

        if (eventData.task == "setUserContacts") {
            qbPhone.setupPlayerContactInfo(eventData.pData.charinfo.firstname, eventData.pData.charinfo.lastname, eventData.pData.charinfo.phone);
            qbPhone.setupPlayerContacts(eventData.pContacts);
        }

        if (eventData.task == "setupBankData") {
            qbPhone.setBankData(eventData.pData)
        }

        if (eventData.task == "updateTime") {
            qbPhone.updateTime(eventData.time)
        }

        if (eventData.task == "getVehicles") {
            qbPhone.setGarageVehicles(eventData.vehicles)
        }

        if (eventData.task == "setupMail") {
            qbPhone.setupUserMails(eventData.mails)
        }

        if (eventData.task == "setupTweets") {
            qbPhone.SetupTweets(eventData.tweets);
        }

        if (eventData.task == "phoneNotify")  {
            qbPhone.Notify(eventData.title, eventData.type, eventData.text, 3500);
        }

        if (eventData.task == "setupAds") {
            qbPhone.SetupAdverts(eventData.ads);
        }

        if (eventData.task == "phoneNotification") {
            qbPhone.phoneNotification(eventData.message)
        }

        if (eventData.task == "newTweet") {
            qbPhone.SetupTweets(eventData.tweets);
            qbPhone.Notify('<i class="fab fa-twitter" style="position: relative; padding-top: 3px;"></i> Twitter', 'tweet', '@'+eventData.sender + ' heeft een tweet geplaatst!')
        }

        if (eventData.task == "setupCompanies") {
            qbPhone.SetupCompanies(eventData.companies);
        }

        if (eventData.task == "newAd") {
            qbPhone.SetupAdverts(eventData.ads);
            qbPhone.Notify('<i class="fas fa-ad" style="position: relative; padding-top: 3px;"></i> Advertentie', 'advert', eventData.sender + ' heeft een advertentie geplaatst!')
        }

        if (eventData.task == "updateChat") {
            qbPhone.UpdateChat(eventData.messages, eventData.number)
        }

        if (eventData.task == "updateChats") {
            $.post('http://qb-phone/getMessages', JSON.stringify({}), function(messages){
                qbPhone.SetupChat(messages)
            });
        }

        if (eventData.task == "newMessage") {
            qbPhone.Notify('<i class="fas fa-envelope" style="position: relative; padding-top: 7px;"></i> Berichten', 'success', eventData.sender + ' heeft een bericht gestuurd!')
        }

        if (eventData.task == "newPoliceAlert") {
            qbPhone.AddPoliceAlert(eventData);
        }

        if (eventData.task == "suggestedNumberNotify") {
            suggestedNumber = eventData.number
            $(".suggestedContact").css({"bottom":"40%"});
            $(".suggestedContact").fadeIn(250);
        }

        if (eventData.task ==  "suggestedBankAccountNotify") {
            suggestedBank = eventData.nr
            $(".suggestedBank").css({"bottom":"40%"});
            $(".suggestedBank").fadeIn(250);
        }

        if (eventData.task == "OpenPayPhone") {
            qbPhone.OpenPayPhone();
        }
    });

    $('.notify-btn').change(function() {
        if (allowNotifys == null) {
            if (myNotify) {
                allowNotifys = true;
                qbPhone.toggleNotify(true)
            } else {
                allowNotifys = false;
                qbPhone.toggleNotify(false)
            }
        } else {
            if (!allowNotifys) {
                allowNotifys = true;
                qbPhone.toggleNotify(true)
            } else {
                allowNotifys = false;
                qbPhone.toggleNotify(false)
            }
        }
    })
});

$(document).on('click', '#suggestedContact-accept', function(e){
    e.preventDefault();

    $(".suggestedContact").fadeOut(250);
    $(".suggestedContact").css({"bottom":"-40%"});

    $.post('http://qb-phone/setupContacts');

    $(".contacts-app").css({'display':'block'}).animate({
        top: "3%",
    }, 250, function(){
        $('.add-contact-container').css({"display":"block"}).animate({top: "20%",}, 250);
        setTimeout(function(){
            $(".contactname-input").val("");
            $(".number-input").val(suggestedNumber);
            addingContact = true;
        }, 100)
    });

    qbPhone.succesSound();

    currentApp = ".contacts-app";
})

$(document).on('click', '#suggestedContact-deny', function(e){
    e.preventDefault();

    suggestedNumber = null;

    $(".suggestedContact").fadeOut(250);
    $(".suggestedContact").css({"bottom":"-40%"});
})

$(document).on('click', '#suggestedBank-accept', function(e){
    e.preventDefault();

    $(".suggestedBank").fadeOut(250);
    $(".suggestedBank").css({"bottom":"-40%"});
    
    $.post('http://qb-phone/getBankData');

    $(".bank-app").css({'display':'block'}).animate({
        top: "3%",
    }, 250, function(){
        $('.transfer-money-container').css({"display":"block"}).animate({top: "18.5%",}, 250);
        setTimeout(function(){
            $(".iban-input").val(suggestedBank);
            $(".euro-amount-input").val("");
        }, 100)
    });

    qbPhone.succesSound();

    currentApp = ".bank-app";
})

$(document).on('click', '#suggestedBank-deny', function(e){
    e.preventDefault();

    suggestedBank = null;

    $(".suggestedBank").fadeOut(250);
    $(".suggestedBank").css({"bottom":"-40%"});
});

$(document).on('click', '.app', function(e){
    e.preventDefault();

    var appId = $(this).attr('id');
    var pressedApp = $('#'+appId).data('appData');

    $("."+pressedApp.app+"-app").css({'display':'block'}).animate({
        top: "3%",
    }, 250);

    currentApp = "."+pressedApp.app+"-app";

    if (suggestedNumber !== null) {
        $(".suggestedContact").css({"bottom":"40%"});
        $(".suggestedContact").fadeOut(250);
    }

    if (pressedApp.app == "contacts") {
        $.post('http://qb-phone/setupContacts');
    } else if (pressedApp.app == "bank") {
        $.post('http://qb-phone/getBankData');
    } else if (pressedApp.app == "garage") {
        $.post('http://qb-phone/getVehicles');
    } else if (pressedApp.app == "mails") {
        $.post('http://qb-phone/getUserMails');
    } else if (pressedApp.app == "twitter") {
        $.post('http://qb-phone/getTweets');
    } else if (pressedApp.app == "advert") {
        $.post('http://qb-phone/getAds');
    } else if (pressedApp.app == "messages") {
        $.post('http://qb-phone/getMessages', JSON.stringify({}), function(messages){
            qbPhone.SetupChat(messages)
        });
    } else if (pressedApp.app == "police") {
        $.post('http://qb-phone/getCharacterData', JSON.stringify({}), function(charinfo){
            qbPhone.SetupPoliceApp(charinfo)
        });
    } else if (pressedApp.app == "companies") {
        $.post('http://qb-phone/getCompanies');
    }

    qbPhone.succesSound();
});

qbPhone.SetupPoliceApp = function(data) {
    $(".app-character-name").html("Welkom " + data.firstname + " " + data.lastname);
}

$(document).on('click', '.police-tab-item', function(e){
    e.preventDefault();
    var tab = $(this).attr("id");
    if (tab == "person") {
        $(".police-tabs").fadeOut(150, function() {
            $(".police-person").fadeIn(150);
        });
        
        lastPage = currentApp
        currentApp = ".police-person"
    } else if (tab == "vehicle") {
        $(".police-tabs").fadeOut(150, function() {
            $(".police-vehicle").fadeIn(150);
        });
        
        lastPage = currentApp
        currentApp = ".police-vehicle"
    } else if (tab == "alerts") {
        $(".police-tabs").fadeOut(150, function() {
            $(".police-alerts").fadeIn(150);
        });
        
        lastPage = currentApp
        currentApp = ".police-alerts"
    }
});

$(document).on('click', '.person-found-item', function(e){
    e.preventDefault();
    $(".person-found-item").each(function(index) {
        var person = $(this).data("personData");
        $(this).html('<p class="person-name">Naam: '+person.firstname+' '+person.lastname+'</p><p class="person-citizenid">BSN: '+person.citizenid+'</p>')
    });
    var person = $(this).data("personData");
    var status = '<span class="person-status-inactive">Nee</span>'
    var driverlicense = '<span class="person-status-inactive">Ja</span>'
    var gender = "Man"
    if (person.gender == 1) {
        gender = "Vrouw"
    }
    if (person.warrant) {
        status = '<span class="person-status-active">Ja</span>'
    }
    if (!person.driverlicense) {
        driverlicense = '<span class="person-status-active">Nee</span>'
    }
    $(this).html('<p class="person-name">Naam: '+person.firstname+' '+person.lastname+'</p><p class="person-citizenid">BSN: '+person.citizenid+'</p><hr><p class="person-birthdate">Geboortedatum: '+person.birthdate+'</p><p class="person-phonenumber">Telefoonnummer: '+person.phone+'</p><p class="person-address">Nationaliteit: '+person.nationality+'</p><p class="person-address">Geslacht: '+gender+'</p><br/><p class="person-status">Gesignaleerd: '+status+'</p><p class="person-status">Rijbewijs: '+driverlicense+'</p>');
});

$(document).on('click', '#person-button-search', function(e){
    e.preventDefault();
    var search = $("#person-input-search").val();
    $(".police-person-found").html("");
    $.post('http://qb-phone/policeSearchPerson', JSON.stringify({search: search,}), function(persons){
        if (persons != null) {
            $.each(persons, function (i, person) {
                $(".police-person-found").append('<div class="person-found-item" id="person-'+i+'"><p class="person-name">Naam: '+person.firstname+' '+person.lastname+'</p><p class="person-citizenid">BSN: '+person.citizenid+'</p></div>');
                $("#person-" + i).data("personData", person);
            });
        } else {
            $(".police-person-found").html("<p>Geen persoon gevonden..</p>")
        }
    });
});

$(document).on('click', '.vehicle-found-item', function(e){
    e.preventDefault();
    $(".vehicle-found-item").each(function(index) {
        var vehicleData = $(this).data("vehicleData");
        $(this).html('<p class="vehicle-name">'+vehicleData.label+'</p><p class="vehicle-plate">Kenteken: '+vehicleData.plate+'</p>')
    });
    var vehicleData = $(this).data("vehicleData");
    var status = '<span class="vehicle-status-inactive">Ja</span>'
    if (!vehicleData.status) {
        status = '<span class="vehicle-status-active">Nee</span>'
    }
    var flagged = '<span class="vehicle-status-active">Ja</span>'
    if (!vehicleData.isFlagged) {
        flagged = '<span class="vehicle-status-inactive">Nee</span>'
    }
    $(this).html('<p class="vehicle-name">'+vehicleData.label+'</p><p class="vehicle-plate">Kenteken: '+vehicleData.plate+'</p><hr><p class="vehicle-person">Eigenaar: '+vehicleData.owner+' ('+vehicleData.citizenid+')</p><br/><p class="vehicle-status">APK: '+status+'</p><p class="vehicle-status">Gesignaleerd: '+flagged+'</p>');
});

$(document).on('click', '#vehicle-button-search', function(e){
    e.preventDefault();
    var search = $("#vehicle-input-search").val();
    $(".police-vehicle-found").html("");
    $.post('http://qb-phone/policeSearchVehicle', JSON.stringify({search: search,}), function(vehicles){
        if (vehicles != null) {
            $.each(vehicles, function (i, vehicleData) {
                $(".police-vehicle-found").append('<div class="vehicle-found-item" id="vehicle-'+i+'"><p class="vehicle-name">'+vehicleData.label+'</p><p class="vehicle-plate">Kenteken: '+vehicleData.plate+'</p></div>');
                console.log(vehicleData);
                $("#vehicle-" + i).data("vehicleData", vehicleData);
            });
        } else {
            $(".police-vehicle-found").html("<p>Geen persoon gevonden..</p>")
        }
    });
});

$(document).on('click', '#vehicle-button-scan', function(e){
    e.preventDefault();
    $(".vehicle-found-item").html("")
    $.post('http://qb-phone/scanVehiclePlate', JSON.stringify({}), function(vehicleData){
        var status = '<span class="vehicle-status-inactive">Ja</span>'
        if (!vehicleData.status) {
            status = '<span class="vehicle-status-active">Nee</span>'
        }
        var flagged = '<span class="vehicle-status-active">Ja</span>'
        if (!vehicleData.isFlagged) {
            flagged = '<span class="vehicle-status-inactive">Nee</span>'
        }
        $(".police-vehicle-found").html('<div class="vehicle-found-item"><p class="vehicle-name">'+vehicleData.label+'</p><p class="vehicle-plate">Kenteken: '+vehicleData.plate+'</p><hr><p class="vehicle-person">Eigenaar: '+vehicleData.owner+' ('+vehicleData.citizenid+')</p><br/><p class="vehicle-status">APK: '+status+'</p><p class="vehicle-status">Gesignaleerd: '+flagged+'</p></div>');
    });
});

qbPhone.AddPoliceAlert = function(data) {
    var randId = Math.floor((Math.random() * 10000) + 1);
    if (data.alert.coords != undefined && data.alert.coords != null) {
        $(".police-incomming-alerts").prepend('<div class="police-alert-item" id="alert-'+randId+'"><span class="badge badge-danger alert-new" style="margin-bottom: 1vh;">NIEUW</span><p class="alert-title">Melding: '+data.alert.title+'</p><p class="alert-description">'+data.alert.description+'</p><hr><button type="button" class="btn police-light-button alert-location">LOCATIE</button></div>');
    } else {
        $(".police-incomming-alerts").prepend('<div class="police-alert-item" id="alert-'+randId+'"><span class="badge badge-danger alert-new" style="margin-bottom: 1vh;">NIEUW</span><p class="alert-title">Melding: '+data.alert.title+'</p><p class="alert-description">'+data.alert.description+'</p></div>');
    }
    $("#alert-"+randId).data("alertData", data.alert);
}

$(document).on('click', '.alert-location', function(e){
    e.preventDefault();
    var alertData = $(this).parent().data("alertData");
    $.post('http://qb-phone/setAlertWaypoint', JSON.stringify({
        alert: alertData,
    }))
});

$(document).on('click', '#alert-button-clear', function(e){
    e.preventDefault();
    $(".police-alert-item").remove();
});

qbPhone.SetupChat = function(chats) {
    $(".chats-container").html("");
    $.each(chats, function(i, chat){
        var chatLength = chat.messages.length;
        var elem = '<div class="chat" id="chat-'+i+'"><span id="chat-name">'+chat.name+'</span> <span id="chat-last-message">'+chat.messages[chatLength - 1].message+'</span> <span id="chat-last-message-date"><span id="chat-last-message-state">Nieuw &#8226;</span> Vandaag</span> </div>';
        $(".chats-container").append(elem);
        $("#chat-"+i).data('chatData', chat);
    });
}

$(document).on('click', '#chat-window-arrow-left', function(e){
    e.preventDefault();

    $('.chat-window').css({"display":"block"}).animate({top: "103.5%",}, 250, function(){
        $(".chat-window").css({"display":"none"});
    });

    currentChatNumber = null;
})

var chatData = null;

$(document).on('click', '.chat', function(e){
    e.preventDefault();
    chatData = $(this).data('chatData');
    currentChatNumber = chatData.number;
    $(".messages").html("");
    $('.chat-window').css({"display":"block"}).animate({top: "3%",}, 250);
    $(".chat-window-header").html('<p><i class="fas fa-arrow-left" id="chat-window-arrow-left"></i> '+chatData.name+'</p>');
    $.each(chatData.messages, function(i, chat){
        if (chat.sender != myCitizenId) {
            if (chat.type == "normal") {
                var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                $(".messages").append(elem);
            } else {
                var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                $(".messages").append(elem);
            }
        }
        if (chat.sender == myCitizenId) {
            if (chat.type == "normal") {
                var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                $(".messages").append(elem);
            } else {
                var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                $(".messages").append(elem);
            }
        }
    });
    qbPhone.loadUserMessages();
});

$(document).on('click', '.msg-me-location', function(e){
    e.preventDefault();

    var messageCoords = {}
    messageCoords.x = $(this).data('x');
    messageCoords.y = $(this).data('y');

    $.post('http://qb-phone/setMessageLocation', JSON.stringify({
        msgCoords: messageCoords
    }))
});

$(document).on('click', '.msg-other-location', function(e){
    e.preventDefault();

    var messageCoords = {}
    messageCoords.x = $(this).data('x');
    messageCoords.y = $(this).data('y');

    $.post('http://qb-phone/setMessageLocation', JSON.stringify({
        msgCoords: messageCoords
    }))
});

qbPhone.UpdateChat = function(messages, number) {
    if (currentChatNumber == number) {
        $(".messages").html("");
        $.each(messages, function(i, chat){
            if (chat.sender != myCitizenId) {
                if (chat.type == "normal") {
                    var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                    $(".messages").append(elem);
                } else {
                    var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                    $(".messages").append(elem);
                }
            }
            if (chat.sender == myCitizenId) {
                if (chat.type == "normal") {
                    var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                    $(".messages").append(elem);
                } else {
                    var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                    $(".messages").append(elem);
                }
            }
        });
        qbPhone.loadUserMessages();
    }
}

$(document).on('click', '.send-message', function(e){
    e.preventDefault();

    var message = $(".message-input").val();

    if (message != "") {
        $.post('http://qb-phone/sendMessage', JSON.stringify({
            number: chatData.number,
            message: message,
            type: "normal"
        }), function(cData){
            $(".messages").html("");
            chatData.messages = cData;
            $.each(cData, function(i, chat){
                if (chat.sender != myCitizenId) {
                    if (chat.type == "normal") {
                        var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                        $(".messages").append(elem);
                    } else {
                        var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                        $(".messages").append(elem);
                    }
                }
                if (chat.sender == myCitizenId) {
                    if (chat.type == "normal") {
                        var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                        $(".messages").append(elem);
                    } else {
                        var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                        $(".messages").append(elem);
                    }
                }
            });
            qbPhone.loadUserMessages();
        });
    
        $.post('http://qb-phone/getMessages', JSON.stringify({}), function(messages){
            qbPhone.SetupChat(messages)
        });
    
        $(".message-input").val("");
    }
});

$(document).on('click', '.send-location', function(e){
    e.preventDefault();

    $.post('http://qb-phone/sendMessage', JSON.stringify({
        number: chatData.number,
        type: "gps"
    }), function(cData){
        $(".messages").html("");
        chatData.messages = cData;
        $.each(cData, function(i, chat){
            if (chat.sender != myCitizenId) {
                if (chat.type == "normal") {
                    var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                    $(".messages").append(elem);
                } else {
                    var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                    $(".messages").append(elem);
                }
            }
            if (chat.sender == myCitizenId) {
                if (chat.type == "normal") {
                    var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                    $(".messages").append(elem);
                } else {
                    var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                    $(".messages").append(elem);
                }
            }
        });
        qbPhone.loadUserMessages();
    });

    $.post('http://qb-phone/getMessages', JSON.stringify({}), function(messages){
        qbPhone.SetupChat(messages)
    });
})

qbPhone.SendMessage = function() {
    var message = $(".message-input").val();

    if (currentChatNumber != null) {
        if (message != "") {
            $.post('http://qb-phone/sendMessage', JSON.stringify({
                number: chatData.number,
                message: message
            }), function(cData){
                $(".messages").html("");
                chatData.messages = cData;
                $.each(cData, function(i, chat){
                    if (chat.sender != myCitizenId) {
                        if (chat.type == "normal") {
                            var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                            $(".messages").append(elem);
                        } else {
                            var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                            $(".messages").append(elem);
                        }
                    }
                    if (chat.sender == myCitizenId) {
                        if (chat.type == "normal") {
                            var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                            $(".messages").append(elem);
                        } else {
                            var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                            $(".messages").append(elem);
                        }
                    }
                });
                qbPhone.loadUserMessages();
            });
        
            $.post('http://qb-phone/getMessages', JSON.stringify({}), function(messages){
                qbPhone.SetupChat(messages)
            });
        
            $(".message-input").val("");
        }
    }
}

$(document).on('click', '.sms-contact', function(){
    var cId = $(this).attr('id');
    var contactData = $("#"+cId).data('cData');

    $.post('http://qb-phone/doesChatExists', JSON.stringify({
        cData: contactData
    }), function(cbData){
        if (cbData != "") {
            qbPhone.OpenExistingChat(cbData)
        } else {
            qbPhone.OpenNewChat(contactData)
        }
    });
    currentChatNumber = contactData.number;
    qbPhone.loadUserMessages();
});

qbPhone.OpenExistingChat = function(messageData) {
    $('.chat-window').css({"display":"block"}).animate({top: "3%",}, 250);
    $(".chat-window-header").html('<p><i class="fas fa-arrow-left" id="chat-window-arrow-left"></i> '+messageData.name+'</p>');
    $(".messages").html("");
    $(".contacts-app").css({'display':'block'}).animate({
        top: "103.5%",
    }, 250, function(){
        $(".contacts-app").css({'display':'none'});
        $(".messages-app").css({'display':'block'}).animate({
            top: "3%",
        }, 250);
        currentApp = ".messages-app";
    });
    chatData = messageData;
    $.each(messageData.messages, function(i, chat){
        if (chat.sender != myCitizenId) {
            if (chat.type == "normal") {
                var elem = '<div class="msg-container msg-other">'+chat.message+'</div>'
                $(".messages").append(elem);
            } else {
                var elem = '<div class="msg-container msg-other msg-other-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                $(".messages").append(elem);
            }
        }
        if (chat.sender == myCitizenId) {
            if (chat.type == "normal") {
                var elem = '<div class="msg-container msg-me">'+chat.message+'</div>'
                $(".messages").append(elem);
            } else {
                var elem = '<div class="msg-container msg-me msg-me-location" data-x="'+chat.coords.x+'" data-y="'+chat.coords.y+'"><i>'+chat.message+'</i></div>'
                $(".messages").append(elem);
            }
        }
    });
    qbPhone.loadUserMessages();
}

qbPhone.OpenNewChat = function(data) {
    $('.chat-window').css({"display":"block"}).animate({top: "3%",}, 250);
    $(".chat-window-header").html('<p><i class="fas fa-arrow-left" id="chat-window-arrow-left"></i> '+data.name+'</p>');
    $(".messages").html("");
    $(".contacts-app").css({'display':'block'}).animate({
        top: "103.5%",
    }, 250, function(){
        $(".contacts-app").css({'display':'none'});
        $(".messages-app").css({'display':'block'}).animate({
            top: "3%",
        }, 250);
        currentApp = ".messages-app";
    });
    chatData = data;
    qbPhone.loadUserMessages();
}

$(document).on('click', '#background-item', function(e){
    e.preventDefault();

    $('.background-block').css({"display":"block"}).animate({top: "20%",}, 250);
    setTimeout(function(){
        choosingBg = true;
    }, 100)
    qbPhone.succesSound();
});

$(document).on('click', '.add-contact-btn', function(e){
    e.preventDefault();

    $('.add-contact-container').css({"display":"block"}).animate({top: "20%",}, 250);
    setTimeout(function(){
        $(".contactname-input").val("");
        $(".number-input").val("");
        addingContact = true;
    }, 100)
    qbPhone.succesSound();
});

$(document).on('click', '.submit-contact-btn', function(e){
    var contactName = $(".contactname-input").val();
    var contactNum = $(".number-input").val();

    if(contactName != "" || contactNum != "") {
        if (!isNaN(contactNum)) {
            $('.add-contact-container').css({"display":"block"}).animate({top: "103%",}, 250);
            qbPhone.Notify('Contacten', 'success', contactName+" ("+contactNum+") is toegevoegd aan je contacten.")
            $.post('http://qb-phone/addToContact', JSON.stringify({
                contactName: contactName,
                contactNum: contactNum
            }))
        } else {
            qbPhone.Notify('Contacten', 'error', 'Het telefoon nummer moet bestaan uit cijfers.')
        }
    } else {
        qbPhone.Notify('Contacten', 'error', 'Je hebt niet alle contactgegevens ingevuld.')
    }
});

$(document).on('click', '.back-contact-btn', function(e){
    $('.add-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".add-contact-container").css({"display":"none"});
    });
});

$(document).on('click', '.back-transfer-btn', function(e){
    $('.transfer-money-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.transfer-money-container').css({'display':'none'});
    });
});

$(document).on('click', '.back-quit-btn', function(e){
    $('.quit-confirm-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.quit-confirm-container').css({'display':'none'});
    });
});

$(document).on('click', '.companies-quit-btn', function(e){
    $('.quitperson-confirm-container').css({"display":"block"}).animate({top: "18.5%",}, 150);
    $(".submit-quitperson-btn").data("companyData", $(this).data("companyData"));
});

$(document).on('click', '.companies-quit-small-btn', function(e){
    $('.quit-confirm-container').css({"display":"block"}).animate({top: "18.5%",}, 150);
    $(".submit-quit-btn").data("companyData", $(this).data("companyData"));
});

$(document).on('click', '.companies-settings-small-btn', function(e){
    $('.companies-home').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.companies-home').css({'display':'none'});
        $('.companies-settings').css({"display":"block"}).animate({top: "5%",}, 150);
        $(".employees-buttons").html("");
    });
});

$(document).on('click', '.bank-transfer-btn', function(e){
    $('.transfer-money-container').css({"display":"block"}).animate({top: "18.5%",}, 150);
});

$(document).on('click', '.submit-quit-btn', function(e){
    var companyData = $(this).data("companyData");
    $.post('http://qb-phone/removeCompany', JSON.stringify({
        name: companyData.name,
    }))
    $('.quit-confirm-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.quit-confirm-container').css({'display':'none'});
        $(".companies-buttons").html("");
    });
});

$(document).on('click', '.submit-quitperson-btn', function(e){
    var companyData = $(this).data("companyData");
    $.post('http://qb-phone/quitCompany', JSON.stringify({
        name: companyData.name,
    }))
    $('.quitperson-confirm-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $('.quitperson-confirm-container').css({'display':'none'});
        $(".companies-buttons").html("");
    });
});

$(document).on('click', '.submit-transfer-btn', function(e){
    var ibanVal = $(".iban-input").val();
    var amountVal = parseInt($(".euro-amount-input").val());
    var balance = parseInt($(".account-balance").data('balance'));

    console.log(balance)
    console.log(amountVal)
    console.log(balance - amountVal)

    if (ibanVal != "" && amountVal != "") {
        if (!isNaN(amountVal)) {
            if (balance - amountVal < 0) {
                qbPhone.Notify('QBank', 'error', 'Je hebt niet genoeg saldo', 3500);
            } else {
                if (amountVal > 0) {
                    $('.transfer-money-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
                        $('.transfer-money-container').css({'display':'none'});
                        qbPhone.Notify('QBank', 'success', 'Je hebt € '+amountVal+' overgemaakt naar '+ibanVal+'!', 3500);
    
                        $.post('http://qb-phone/transferMoney', JSON.stringify({
                            amount: amountVal,
                            iban: ibanVal
                        }));
    
                        $(".account-balance").html("&euro; "+parseInt((balance - amountVal))+",-");
                        $(".account-balance").data('balance', parseInt((balance - amountVal)));
                    });
                } else {
                    qbPhone.Notify('QBank', 'error', 'Hoeveelheid mag niet lager zijn dan 0', 3500);
                }
            }
        } else {
            qbPhone.Notify('QBank', 'error', 'De hoeveelheid moet bestaan uit cijfers.', 3500)
        }
    } else {
        qbPhone.Notify('QBank', 'error', 'Je hebt niet alle gegevens ingevuld.', 3500)
    }
});

$(document).on('click', '.settings-app', function(e){
    if (choosingBg) {
        $('.background-block').animate({top: "100%",}, 
        250, function(){
            $('.background-block').css({'display':'none'});
            choosingBg = false;
        });
    }
});

$(document).on('click', '.background-option', function(e){
    e.preventDefault();

    var selectedBackground = $(this).attr('id');
    $(".phone-home-page").css("background-image", "url(./img/"+selectedBackground+".png)");
    $("#"+curBg).removeClass("selected-bg");
    $(this).addClass("selected-bg");
    curBg = $(this).attr("id");

    if (curBg == "bg-1") {
        $("#current-background").html("Gradient Green");
    } else if (curBg == "bg-2") {
        $("#current-background").html("Abstract");
    }
    $.post('http://qb-phone/setPlayersBackground', JSON.stringify({
        background: selectedBackground
    }))
    qbPhone.succesSound();
});

$(document).on('click', '.home-container', function(e){
    e.preventDefault();
    if (lastPage == null) {
        if (currentApp != homePage) {
            $(currentApp).animate({top: "100%",}
            , 250, function() {
                $(currentApp).css({'display':'none'});
                $(homePage).css({'display':'block'});
                currentApp = homePage;
            });
    
            qbPhone.succesSound();
        } else {
            qbPhone.Close();
        }
    } else if (lastPage == ".police-app") {
        $(currentApp).fadeOut(150, function(){
            if (currentApp == ".police-alerts") {
                $(".alert-new").remove();
            }
            $(".police-tabs").fadeIn(150);
            currentApp = lastPage;
            lastPage = null;
        });
    } else {
        $(currentApp).animate({top: "100%",}
        , 250, function() {
            $(currentApp).css({'display':'none'});
            $(lastPage).css({'display':'block'});
            currentApp = lastPage;
            lastPage = null;
        });

        buttonEvent = null
        buttonData = null
        mailId = null
    
        qbPhone.succesSound();
    }

    $('.chat-window').css({"display":"block"}).animate({top: "103.5%",}, 250, function(){
        $(".chat-window").css({"display":"none"});
    });
});

qbPhone.Open = function(cid) {
    inPhone = true;
    $(homePage).css({'display':'block'})
    $('.phone-container').css({'display':'block'}).animate({
        top: "41.3%",
    }, 300);
    $('.phone-frame').css({'display':'block'}).animate({
        top: "40%",
    }, 300);
    myCitizenId = cid;
}

qbPhone.Close = function() {
    $(".payphone").fadeOut(150);
    $.post('http://qb-phone/closePayPhone');
    inPhone = false;
    $('.phone-container').css({'display':'block'}).animate({
        top: "100%",
    }, 300);
    $('.phone-frame').css({'display':'block'}).animate({
        top: "100%",
    }, 300, function(){
        if (currentApp == ".opened-mail") {
            $(currentApp).animate({top: "100%",}, 250, function() {
                $(currentApp).css({'display':'none'});
            });
            $(".mails-app").animate({top: "100%",}, 250, function() {
                $(".mails-app").css({'display':'none'});
                $(homePage).css({'display':'block'});
                currentApp = homePage;
            });
        } else if (currentApp == ".call-app") {
            $(currentApp).css({"display":"none"});
        } else if (currentApp == ".police-app" || currentApp == ".police-tabs" || currentApp == ".police-person" || currentApp == ".police-vehicle" || currentApp == ".police-alerts") {
            if (currentApp == ".police-alerts") {
                $(".alert-new").remove();
            }
            $(".police-app").css({"display":"none"});
            $(".police-tabs").css({"display":"block"});
            $(".police-person").css({"display":"none"});
            $(".police-vehicle").css({"display":"none"});
            $(".police-alerts").css({"display":"none"});
            $(homePage).css({'display':'block'});
            currentApp = homePage;
        } else {
            if (currentApp != homePage) {
                $(currentApp).animate({top: "100%",}
                , 250, function() {
                    $(currentApp).css({'display':'none'});
                    $(homePage).css({'display':'block'});
                    currentApp = homePage;
                });
            } 
        }
    });
    $.post('http://qb-phone/closePhone');

    $('.chat-window').css({"display":"block"}).animate({top: "103.5%",}, 250, function(){
        $(".chat-window").css({"display":"none"});
    });
}

qbPhone.setupPhoneApps = function(apps) {
    $('.app-slot').html("");
    $.each(apps, function(index, app) {
        if (index == "police") {
            var appElement = '<div class="app" id="slot-'+app.slot+'" style="background-color: '+app.color+';" data-toggle="tooltip" data-placement="bottom" title="'+app.tooltipText+'"><img src="img/politie.png" width="20" height="26" alt="police" style="margin-left: 0.65vw!important;margin-top: 0.7vh!important;" /></div>'
            $('.slot-'+app.slot).append(appElement);
            $('.slot-'+app.slot).removeClass("empty-slot");
            $('#slot-'+app.slot).data('appData', app);
        } else {
            var appElement = '<div class="app" id="slot-'+app.slot+'" style="background-color: '+app.color+';" data-toggle="tooltip" data-placement="bottom" title="'+app.tooltipText+'"><i class="'+app.icon+'" id="app-icon" style="'+app.style+'"></i></div>'
            $('.slot-'+app.slot).append(appElement);
            $('.slot-'+app.slot).removeClass("empty-slot");
            $('#slot-'+app.slot).data('appData', app);
        }
        
    });
    $('[data-toggle="tooltip"]').tooltip();
    phoneApps = apps
}

qbPhone.Log = function(log) {
    console.log(log)
}

qbPhone.toggleNotify = function(bool) {
    allowNotifys = bool;
    if (bool) {
        $(".notify-state").html("Aan");
    } else {
        $(".notify-state").html("Uit");
    }

    $.post('http://qb-phone/setNotifications', JSON.stringify({allow: bool}));
    qbPhone.succesSound();
}

qbPhone.succesSound = function() {
    $.post('http://qb-phone/succesSound');
}

qbPhone.errorSound = function() {
    $.post('http://qb-phone/errorSound');
}

qbPhone.setPhoneMeta = function(phoneMeta, phoneNumber) {
    qbPhone.setPlayersNotification(phoneMeta.settings.notification)
    qbPhone.setPlayersBackground(phoneMeta.settings.background)
    qbPhone.setPlayersPhoneNumber(phoneNumber)
}

qbPhone.setPlayersNotification = function(allow) {
    myNotify = allow;
    if (allow) {
        $("#notification-toggle").bootstrapToggle('on')
    } else {
        $("#notification-toggle").bootstrapToggle('off')
    }
}

qbPhone.setPlayersPhoneNumber = function(num) {
    $('.phone-num').html(num);
}

qbPhone.setPlayersBackground = function(background) {
    $(".phone-home-page").css("background-image", "url(./img/"+background+".png)");
    $("#"+background).addClass("selected-bg");
    curBg = background;
    $("#current-background").html("Gradient Green");
    if (background == "bg-1") {
        $("#current-background").html("Gradient Green");
    } else if (background == "bg-2") {
        $("#current-background").html("Abstract");
    }
}

qbPhone.updateTime = function(time) {
    $("#time").html(time.hour+"."+time.minute);
}

qbPhone.setupPlayerContactInfo = function(firstName, lastName, phoneNumber) {
    $("#firstletters").html((firstName).charAt(0).toUpperCase()+""+(lastName).charAt(0).toUpperCase());
    $("#myi-number").html(phoneNumber);
}

var editContactData = null;

$(document).on('click', '.edit-contact', function(e){
    e.preventDefault();

    var cId = $(this).attr('id');
    var contactData = $("#"+cId).data('cData');

    $('.edit-contact-container').css({"display":"block"}).animate({top: "20%",}, 250);
    editContactData = contactData;
    setTimeout(function(){
        $(".edit-contactname-input").val(contactData.name);
        $(".edit-number-input").val(contactData.number);
    }, 100)
    qbPhone.succesSound();
})

$(document).on('click', '.call-contact', function(e){
    e.preventDefault();

    var cId = $(this).attr('id');
    var contactData = $("#"+cId).data('cData');

    qbPhone.Close();

    $.post('http://qb-phone/CallContact', JSON.stringify({
        contactData: contactData
    }))

    qbPhone.succesSound();
})

$(document).on('click', '.incoming-call-answer', function(e){
    e.preventDefault(); 

    $.post('http://qb-phone/AnswerCall');
    $(".incoming-call").css({"display":"none"});
    $(".busy-call").css({"display":"block"});
    qbPhone.Close();
})
$(document).on('click', '.incoming-call-deny', function(e){
    e.preventDefault(); 

    $.post('http://qb-phone/DenyCall');
    if (currentApp != homePage) {
        $(currentApp).animate({top: "100%",}
        , 250, function() {
            $(currentApp).css({'display':'none'});
            $(homePage).css({'display':'block'});
            currentApp = homePage;
        });
    } 
})
$(document).on('click', '.busy-call-deny', function(e){
    e.preventDefault(); 

    $.post('http://qb-phone/DenyCall');
    if (currentApp != homePage) {
        $(currentApp).animate({top: "100%",}
        , 250, function() {
            $(currentApp).css({'display':'none'});
            $(homePage).css({'display':'block'});
            currentApp = homePage;
        });
    } 
})

$(document).on('click', '.back-edit-contact-btn', function(e){
    $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".edit-contact-container").css({"display":"none"});
    });

    editContactData = null;
});

$(document).on('click', '.change-contact-btn', function(e){
    var oldContactName = editContactData.name;
    var oldContactNum =  editContactData.number;

    if($(".edit-number-input").val() != "" || $(".edit-contactname-input").val() != "") {
        if (!isNaN($(".edit-number-input").val())) {
            $.post('http://qb-phone/editContact', JSON.stringify({
                oldContactName: oldContactName,
                oldContactNum: oldContactNum,
                newContactName: $(".edit-contactname-input").val(),
                newContactNum: $(".edit-number-input").val(),
            }))
            qbPhone.Notify('Contacten', 'success', 'Contact opgeslagen');
            $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
                $(".edit-contact-container").css({"display":"none"});
            });
        } else {
            qbPhone.Notify('Contacten', 'error', 'Het telefoon nummer moet bestaan uit cijfers.')
        }
    } else {
        qbPhone.Notify('Contacten', 'error', 'Je hebt niet alle contactgegevens ingevuld.')
    }

    editContactData = null;
});

function changecName() {
    var currentVal = $(".contactname-input").val();

    $(".contactname-input").val(currentVal);
}

$(document).on('click', '.delete-contact-btn', function(e){
    e.preventDefault();

    $('.edit-contact-container').css({"display":"block"}).animate({top: "103%",}, 250, function(){
        $(".edit-contact-container").css({"display":"none"});
    });    

    var oldContactName = editContactData.name;
    var oldContactNum =  editContactData.number;
    
    $.post('http://qb-phone/removeContact', JSON.stringify({
        oldContactName: oldContactName,
        oldContactNum: oldContactNum,
    }))

    editContactData = null;
});

qbPhone.setupPlayerContacts = function(contacts) {
    $(".contact-list").html("");
    $.each(contacts, function(index, contact){
        var contactHTML = '<div class="contact"><div class="contact-status" id="contact-'+index+'"></div><div class="contact-options">' +
        '<div class="contact-option call-contact" id="cData-'+index+'"><i class="fa fa-phone" id="call-contact-icon"></i></div>' +
        '<div class="contact-option sms-contact" id="cData-'+index+'"><i class="fa fa-sms" id="sms-contact-icon"></i></div>' +
        '<div class="contact-option edit-contact" id="cData-'+index+'"><i class="fa fa-edit" id="edit-contact-icon"></i></div></div>' +
        '<span id="contact-name">'+contact.name+'</span></div>'
        $(".contact-list").append(contactHTML);
        if (contact.status === true) {
            $("#contact-"+index).addClass("online");
        } else if (contact.status === false) {
            $("#contact-"+index).addClass("offline");
        }

        $("#contact-"+index).data("contactData", contact);
        $("#cData-"+index).data("cData", contact);
    });
}

var timeout = null;

qbPhone.Notify = function(title, type, message, wait) {
    // if (allowNotifys) {
        if (timeout != undefined) {
            clearTimeout(timeout);
        }
        $('.phone-notify').css({'display':'block', 'top':'-10%'})
        if (type == 'error') {
            $("#notify-titel").css("color", "rgb(126, 9, 9);");
        } else if (type == 'success') {
            $("#notify-titel").css("color", "rgb(9, 126, 9);");
        } else if (type == 'tweet') {
            $("#notify-titel").css("color", "rgb(29, 161, 242);");
        } else if (type == 'advert') {
            $("#notify-titel").css("color", "rgb(255, 143, 26);");
        }

        $("#notify-titel").html(title);
        $("#notify-message").html(message);
        $('.phone-notify').css({'display':'block'}).animate({
            top: "5%",
        }, 300);
        if (wait == null) {
            timeout = setTimeout(function(){
                $('.phone-notify').css({'display':'block'}).animate({
                    top: "-10%",
                }, 300, function(){
                    $('.phone-notify').css({'display':'none'})
                });
            }, 3500)
        } else {
            timeout = setTimeout(function(){
                $('.phone-notify').css({'display':'block'}).animate({
                    top: "-10%",
                }, 300, function(){
                    $('.phone-notify').css({'display':'none'})
                });
            }, wait)
        }
    // }
}

qbPhone.setBankData = function(playerData) {
    console.log(playerData.money.bank)
    $(".account-name").html(playerData.charinfo.firstname+" "+playerData.charinfo.lastname);
    $(".account-balance").html("&euro; "+playerData.money.bank+",-");
    $(".account-balance").data('balance', playerData.money.bank);
    $(".account-number").html(playerData.charinfo.account);
}

qbPhone.setGarageVehicles = function(vehicles) {
    $(".garage-vehicles").html("");
    $.each(vehicles, function(index, vehicle){
        var element = '<div class="garage-vehicle"> '+
        '<div class="garage-vehicle-image" style="background-image: url('+vehicle.image+');"></div>' +
            '<div class="garage-vehicle-name"><p><i class="fas fa-car" id="car-icon"></i> '+vehicle.name+'</p></div>' +
            '<div class="garage-vehicle-garage"><p><i class="fas fa-warehouse" id="warehouse-icon"></i> '+vehicle.garage+'</p></div>' +
            '<div class="garage-vehicle-state"><p><i class="fas fa-parking" id="parking-icon"></i> '+vehicle.state+'</p></div>' +
            '<div class="garage-vehicle-stats"><span id="vehicle-engine"><i class="fas fa-shield-alt" id="body-icon"></i> '+(vehicle.body / 10)+'%  |  </span><span id="vehicle-body"><i class="fas fa-car-battery" id="battery-icon"></i> '+(vehicle.engine / 10)+'%  |  </span><span id="vehicle-fuel"><i class="fas fa-gas-pump" id="fuel-icon"></i> '+(vehicle.fuel / 10)+'%</span></div>' +
            '<div class="garage-vehicle-plate"><p>('+vehicle.plate+')</p></div>' +
        '</div>';

        $(".garage-vehicles").append(element);
    });
}

qbPhone.loadUserMessages = function() {
    var messageScreen = $('.messages');
    var height = messageScreen[0].scrollHeight;
    messageScreen.scrollTop(height);
}

qbPhone.setupUserMails = function(mails) {
    $('.mails-list').html("");
    if (mails != undefined) {
        $.each(mails, function(i, mail){
            if (mail.read == 0) {
                var element = '<div class="mail" id="mail-'+i+'"><div class="mail-sender-dot"></div><span id="mail-sender-name">'+mail.sender+'</span><span id="mail-id">#'+mail.mailid+'</span><span id="mail-subject">'+mail.subject+'</span><span id="mail-message">'+mail.message+'</span></div>';
            } else {
                var element = '<div class="mail" id="mail-'+i+'"><span id="mail-sender-name">'+mail.sender+'</span><span id="mail-id">#'+mail.mailid+'</span><span id="mail-subject">'+mail.subject+'</span><span id="mail-message">'+mail.message+'</span></div>';
            }

            $('.mails-list').append(element);
    
            $('#mail-'+i).data('mailData', mail)
        });
    } else {
        $(".mails-list").html('<span id="no-emails-error">Je inbox is leeg</span>')
    }
}

$(document).on('click', '.mail', function(){
    var curMid = $(this).attr('id');
    var mailData = $('#'+curMid).data('mailData');
    qbPhone.openMail(mailData)
});

$(document).on('click', '.mail-button', function(){
    $.post('http://qb-phone/clickMailButton', JSON.stringify({
        buttonEvent: currentMailEvent,
        buttonData: currentMailData,
        mailId: currentMailId,
    }))

    buttonEvent = null
    buttonData = null
    mailId = null

    qbPhone.Close();
});

$(document).on('click', '#opened-mail-delete-icon', function(){
    $.post('http://qb-phone/removeMail', JSON.stringify({
        mailId: currentMailId
    }))

    $(currentApp).animate({top: "100%",}
    , 250, function() {
        $(currentApp).css({'display':'none'});
        $(lastPage).css({'display':'block'});
        currentApp = lastPage;
        lastPage = null;
    });

    buttonEvent = null
    buttonData = null
    mailId = null

    $.post('http://qb-phone/getUserMails');
});

qbPhone.openMail = function(mailData) {

    var element

    if (mailData.button != undefined) {
        if (mailData.button.enabled) {
            currentMailEvent = mailData.button.buttonEvent;
            currentMailData = mailData.button.buttonData;
            element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
            '<div class="opened-mail-content">' +
            '    <p>'+mailData.message+'</p><div class="mail-button"><p>Accepteren</p></div>' +
            '</div>';
        } else {
            element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
            '<div class="opened-mail-content">' +
            '    <p>'+mailData.message+'</p>' +
            '</div>';
        }
    } else {
        element = '<div class="opened-mail-header"><p>Zender: '+mailData.sender+'</p><p> <span id="opened-mail-subject">Onderwerp: '+mailData.subject+'</span></p><i class="material-icons" id="opened-mail-delete-icon">delete</i></div>' +
        '<div class="opened-mail-content">' +
        '    <p>'+mailData.message+'</p>' +
        '</div>';
    }

    currentMailId = mailData.mailid;

    $(".opened-mail").html(element);

    if (mailData.read == 0) {
        $.post('http://qb-phone/setEmailRead', JSON.stringify({
            mailId: mailData.mailid
        }));
    }

    $(".opened-mail").css({'display':'block'}).animate({
        top: "3%",
    }, 250);

    currentApp = ".opened-mail";
    lastPage = ".mails-app";
}

$(document).on('click', '.twitter-new-tweet', function(){
    $('.twitter-app-new-tweet').css({'display':'block'}).animate({
        bottom: "17vh"
    }, 200);
});


$(document).on('click', '.send-new-tweet', function(){
    var tweetMessage = $('#new-tweet-message').val();

    if (tweetMessage != "") {
        $('.twitter-app-new-tweet').css({'display':'block'}).animate({
            bottom: "-27vh"
        }, 200);
        $.post('http://qb-phone/postTweet', JSON.stringify({
            message: tweetMessage
        }))
    } else {
        qbPhone.Notify('Twitter', 'error', 'Je kan geen legen tweet versturen...')
    }
});

$(document).on('click', '.cancel-new-tweet', function(){
    $('.twitter-app-new-tweet').css({'display':'block'}).animate({
        bottom: "-27vh"
    }, 200);
});

$(document).on('click', '.advert-new-ad', function(){
    $('.advert-app-new-ad').css({'display':'block'}).animate({
        bottom: "17vh"
    }, 200);
});


$(document).on('click', '.send-new-ad', function(){
    var advertMessage = $('#new-advert-message').val();

    if (advertMessage != "") {
        $('.advert-app-new-ad').css({'display':'block'}).animate({
            bottom: "-27vh"
        }, 200);
        $.post('http://qb-phone/postAdvert', JSON.stringify({
            message: advertMessage
        }))
    } else {
        qbPhone.Notify('Advertenties', 'error', 'Je kan geen legen tweet versturen...')
    }
});

$(document).on('click', '.cancel-new-ad', function(){
    $('.advert-app-new-ad').css({'display':'block'}).animate({
        bottom: "-27vh"
    }, 200);
});

var notifyTimer = null;

qbPhone.phoneNotification = function(message) {
    clearTimeout(notifyTimer)
    $(".new-notify").css({"right":"-20%"});
    $('.new-notify-titel').html(message.title);
    $('.new-notify-content').html(message.message);
    if (message.color != undefined) {
        $(".new-notify").css({"background-color":"rgba("+message.color.r+", "+message.color.g+", "+message.color.b+", "+message.color.a+")"})
    }
    $(".new-notify").css({'display':'block'}).animate({
        right: "0%",
    }, 450);
    notifyTimer = setTimeout(function(){
        $(".new-notify").css({'display':'block'}).animate({
            right: "-20%",
        }, 150)
        notifyActive = false;
    }, 3500)
}

qbPhone.SetupTweets = function(tweets) {
    $('.twitter-tweets').html("");
    if (tweets != undefined) {
        $.each(tweets, function(i, tweet){
            var elem = '<div class="twitter-app-tweet"><img src="./img/anonymous-person-icon-0.jpg" alt="anonymous-person-icon-0" class="tweeter-image"><div class="tweet-name"><span id="tweeter-name">'+tweet.sender+'</span> <span id="tweeter-ad">@'+tweet.sender+'</span></div><div class="tweeter-message"><p>'+tweet.message+'</p></div></div>';
    
            $('.twitter-tweets').append(elem);
        });
    } else {
        $(".twitter-tweets").html('<span id="no-emails-error">Er zijn nog<br> geen Tweets geplaatst :(</span>')
    }
}

qbPhone.SetupCompanies = function(companies) {
    $('.companies-accounts-tab').html("");
    if (companies != null && companies != undefined && companies != "") {
        var count = 0;
        $.each(companies, function(i, company){
            count++;
            var elem = '<div class="companies-item" id="company-'+count+'"><p class="company-name">'+company.label+'</p><p class="company-rank">Rank: '+company.rank+'</p></div>';
            $('.companies-accounts-tab').append(elem);
            $("#company-"+count).data("companyData", company);
        });
    } else {
        $(".companies-accounts-tab").html('<p>Je bent nog geen werknemer..</p>')
    }
}

qbPhone.SetupAdverts = function(ads) {
    $('.advert-ads').html("");
    if (ads != undefined) {
        $.each(ads, function(i, ad){
            var elem = '<div class="advert-app-ad"><div class="advert-poster"><span class="poster-name">'+ad.name+'</span> | <span class="poster-phone">'+ad.phone+'</span></div><hr><div class="advert-message"><p>'+ad.message+'</p></div></div>';
    
            $('.advert-ads').append(elem);
        });
    } else {
        $(".advert-ads").html('<span id="no-emails-error">Er zijn nog<br> geen Advertenties geplaatst :(</span>')
    }
}

qbPhone.CallScreen = function(callData) {
    $(".call-app").css({'display':'block'});
    currentApp = ".call-app";
    inCall = true;

    if (callData.outgoingCall) {
        $('.incoming-call').css({"display": "none"});
        $('.busy-call').css({"display": "none"});
        $('.outgoing-call').css({"display": "block"});
    } else if (callData.incomingCall) {
        $('.outgoing-call').css({"display": "none"});
        $('.busy-call').css({"display": "none"});
        $('.incoming-call').css({"display": "block"});
    } else if (callData.inCall) {
        $('.outgoing-call').css({"display": "none"});
        $('.incoming-call').css({"display": "none"});
        $('.busy-call').css({"display": "block"});
    }
    var caller = callData.number
    if (callData.name != null) {caller = callData.name};
    $('.call-number').html("<p>"+caller+"</p>")
}

updateNewBalance = function() {
    var balance = parseInt($(".account-balance").data('balance'));
    var minAmount = $(".euro-amount-input").val();
    $("#new-balance").html(balance - minAmount);
}