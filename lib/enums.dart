
abstract class LiveStatus {
  static const int AVAILABLE = 0;
  static const int OCCUPIED = 1;
  static const int AWAY = 2;
}

abstract class LiveUserStatus {
  static const int CALLER = 1;
  static const int HELPER = 2;
  static const int VIEWER = 3;
}

abstract class CountrySpotMinimumPrice {
  static const int AFRICA = 10;
  static const int EUROPE = 15;
}

abstract class ScheduledTime {
  static const String EIGHT_TO_NINE = '8h00-9h00';
  static const String NINE_TO_TEN = '9h00-10h00';
  static const String TEN_TO_ELEVEN = '10h00-11h00';
  static const String ELEVEN_TO_TWELVE = '11h00-12h00';
  static const String TWELVE_TO_THIRTEEN = '12h00-13h00';
  static const String THIRTEEN_TO_FOURTEEN = '13h00-14h00';
  static const String FOURTEEN_TO_FIFTEEN = '14h00-15h00';
  static const String FIFTEEN_TO_SIXTEEN = '15h00-16h00';
  static const String SIXTEEN_TO_SEVENTEEN = '16h00-17h00';
  static const String SEVENTEEN_TO_EIGHTEEN = '17h00-18h00';
  static const String EIGHTEEN_TO_NINETEEN = '18h00-19h00';
  static const String NINETEEN_TO_TWENTY = '19h00-20h00';
  static const String TWENTY_TO_TWENTY_ONE = '20h00-21h00';
  static const String TWENTY_ONE_TO_TWENTY_TWO = '21h00-22h00';
  static const String TWENTY_TWO_TO_TWENTY_THREE = '22h00-23h00';
  static const String TWENTY_THREE_TO_MIDNIGHT = '23h00-00h00';
  static const String MIDNIGHT_TO_ONE = '00h00-1h00';
  static const String ONE_TO_TWO = '1h00-2h00';
  static const String TWO_TO_THREE = '2h00-3h00';
  static const String THREE_TO_FOUR = '3h00-4h00';
  static const String FOUR_TO_FIVE = '4h00-5h00';
  static const String FIVE_TO_SIX = '5h00-6h00';
  static const String SIX_TO_SEVEN = '6h00-7h00';
  static const String SEVEN_TO_EIGHT = '7h00-8h00';
}

abstract class DaysNotificationIds {
  static const int MONDAY_NOTIFICATION = 100;
  static const int TUESDAY_NOTIFICATION = 200;
  static const int WEDNESDAY_NOTIFICATION = 300;
  static const int THURSDAY_NOTIFICATION = 400;
  static const int FRIDAY_NOTIFICATION = 500;
  static const int SATURDAY_NOTIFICATION = 600;
  static const int SUNDAY_NOTIFICATION = 700;
}

abstract class NotificationId {
  static const int LIVE_CALL = 0;
  static const int INTERNET_CONNECTION_STATUS = 1;
  static const int REQUIREMENTS_ERROR = 2;
  static const int REQUIREMENTS_CURRENTLY_DUE = 3;
  static const int FUTURE_REQUIREMENTS_CURRENTLY_DUE = 4;
  static const int RESERVATION_LIVE_EIGHT_TO_NINE = 8;
  static const int RESERVATION_LIVE_NINE_TO_TEN = 9;
  static const int RESERVATION_LIVE_TEN_TO_ELEVEN = 10;
  static const int RESERVATION_LIVE_ELEVEN_TO_TWELVE = 11;
  static const int RESERVATION_LIVE_TWELVE_TO_THIRTEEN = 12;
  static const int RESERVATION_LIVE_THIRTEEN_TO_FOURTEEN = 13;
  static const int RESERVATION_LIVE_FOURTEEN_TO_FIFTEEN = 14;
  static const int RESERVATION_LIVE_FIFTEEN_TO_SIXTEEN = 15;
  static const int RESERVATION_LIVE_SIXTEEN_TO_SEVENTEEN = 16;
  static const int RESERVATION_LIVE_SEVENTEEN_TO_EIGHTEEN = 17;
  static const int RESERVATION_LIVE_EIGHTEEN_TO_NINETEEN = 18;
  static const int RESERVATION_LIVE_NINETEEN_TO_TWENTY = 19;
  static const int RESERVATION_LIVE_TWENTY_TO_TWENTY_ONE = 20;
  static const int RESERVATION_LIVE_TWENTY_ONE_TO_TWENTY_TWO = 21;
  static const int RESERVATION_LIVE_TWENTY_TWO_TO_TWENTY_THREE = 22;
  static const int RESERVATION_LIVE_TWENTY_THREE_TO_MIDNIGHT = 23;
  static const int RESERVATION_LIVE_MIDNIGHT_TO_ONE = 24;
  static const int RESERVATION_LIVE_ONE_TO_TWO = 25;
  static const int RESERVATION_LIVE_TWO_TO_THREE = 26;
  static const int RESERVATION_LIVE_THREE_TO_FOUR = 27;
  static const int RESERVATION_LIVE_FOUR_TO_FIVE = 28;
  static const int RESERVATION_LIVE_FIVE_TO_SIX = 29;
  static const int RESERVATION_LIVE_SIX_TO_SEVEN = 30;
  static const int RESERVATION_LIVE_SEVEN_TO_EIGHT = 31;
  static const int RESERVATION_REMINDER_LIVE_EIGHT_TO_NINE = 32;
  static const int RESERVATION_REMINDER_LIVE_NINE_TO_TEN = 33;
  static const int RESERVATION_REMINDER_LIVE_TEN_TO_ELEVEN = 34;
  static const int RESERVATION_REMINDER_LIVE_ELEVEN_TO_TWELVE = 35;
  static const int RESERVATION_REMINDER_LIVE_TWELVE_TO_THIRTEEN = 36;
  static const int RESERVATION_REMINDER_LIVE_THIRTEEN_TO_FOURTEEN = 37;
  static const int RESERVATION_REMINDER_LIVE_FOURTEEN_TO_FIFTEEN = 38;
  static const int RESERVATION_REMINDER_LIVE_FIFTEEN_TO_SIXTEEN = 39;
  static const int RESERVATION_REMINDER_LIVE_SIXTEEN_TO_SEVENTEEN = 40;
  static const int RESERVATION_REMINDER_LIVE_SEVENTEEN_TO_EIGHTEEN = 41;
  static const int RESERVATION_REMINDER_LIVE_EIGHTEEN_TO_NINETEEN = 42;
  static const int RESERVATION_REMINDER_LIVE_NINETEEN_TO_TWENTY = 43;
  static const int RESERVATION_REMINDER_LIVE_TWENTY_TO_TWENTY_ONE = 44;
  static const int RESERVATION_REMINDER_LIVE_TWENTY_ONE_TO_TWENTY_TWO = 45;
  static const int RESERVATION_REMINDER_LIVE_TWENTY_TWO_TO_TWENTY_THREE = 46;
  static const int RESERVATION_REMINDER_LIVE_TWENTY_THREE_TO_MIDNIGHT = 47;
  static const int RESERVATION_REMINDER_LIVE_MIDNIGHT_TO_ONE = 48;
  static const int RESERVATION_REMINDER_LIVE_ONE_TO_TWO = 49;
  static const int RESERVATION_REMINDER_LIVE_TWO_TO_THREE = 50;
  static const int RESERVATION_REMINDER_LIVE_THREE_TO_FOUR = 51;
  static const int RESERVATION_REMINDER_LIVE_FOUR_TO_FIVE = 52;
  static const int RESERVATION_REMINDER_LIVE_FIVE_TO_SIX = 53;
  static const int RESERVATION_REMINDER_LIVE_SIX_TO_SEVEN = 54;
  static const int RESERVATION_REMINDER_LIVE_SEVEN_TO_EIGHT = 55;
  static const int USER_ADDED = 56;
  static const int USER_LEFT = 57;
}

 const List<int> g_daysNotifications = [
   DaysNotificationIds.MONDAY_NOTIFICATION,
   DaysNotificationIds.TUESDAY_NOTIFICATION,
   DaysNotificationIds.WEDNESDAY_NOTIFICATION,
   DaysNotificationIds.THURSDAY_NOTIFICATION,
   DaysNotificationIds.FRIDAY_NOTIFICATION,
   DaysNotificationIds.SATURDAY_NOTIFICATION,
   DaysNotificationIds.SUNDAY_NOTIFICATION
 ];

 const List<String> g_scheduledLives = [
  ScheduledTime.EIGHT_TO_NINE,
  ScheduledTime.NINE_TO_TEN,
  ScheduledTime.TEN_TO_ELEVEN,
  ScheduledTime.ELEVEN_TO_TWELVE,
  ScheduledTime.TWELVE_TO_THIRTEEN,
  ScheduledTime.THIRTEEN_TO_FOURTEEN,
  ScheduledTime.FOURTEEN_TO_FIFTEEN,
  ScheduledTime.FIFTEEN_TO_SIXTEEN,
  ScheduledTime.SIXTEEN_TO_SEVENTEEN,
  ScheduledTime.SEVENTEEN_TO_EIGHTEEN,
  ScheduledTime.EIGHTEEN_TO_NINETEEN,
  ScheduledTime.NINETEEN_TO_TWENTY,
  ScheduledTime.TWENTY_TO_TWENTY_ONE,
  ScheduledTime.TWENTY_ONE_TO_TWENTY_TWO,
  ScheduledTime.TWENTY_TWO_TO_TWENTY_THREE,
  ScheduledTime.TWENTY_THREE_TO_MIDNIGHT,
  ScheduledTime.MIDNIGHT_TO_ONE,
  ScheduledTime.ONE_TO_TWO,
  ScheduledTime.TWO_TO_THREE,
  ScheduledTime.THREE_TO_FOUR,
  ScheduledTime.FOUR_TO_FIVE,
  ScheduledTime.FIVE_TO_SIX,
  ScheduledTime.SIX_TO_SEVEN,
  ScheduledTime.SEVEN_TO_EIGHT,
];

Map<String,dynamic> g_daysScheduledLives ={
  'Monday':[],
  'Tuesday':[],
  'Wednesday':[],
  'Thursday':[],
  'Friday':[],
  'Saturday':[],
  'Sunday':[],
};

var error_codes = {
  "account_already_exists": "L'adresse e-mail fournie pour la création d'un compte différé est déjà associée à un compte. Utilisez le flux OAuth pour connecter le compte existant à votre plateforme.",
  "account_country_invalid_address": "Le pays de l'adresse professionnelle fournie ne correspond pas au pays du compte. Les entreprises doivent être situées dans le même pays que le compte.",
  "account_invalid": "L'ID de compte fourni comme valeur pour l'en-tête Stripe-Account n'est pas valide. Vérifiez que vos demandes spécifient un identifiant de compte valide.",
  "account_number_invalid": "Le numéro de compte bancaire fourni n'est pas valide (par exemple, des chiffres manquants).",
  "alipay_upgrade_required": "Cette méthode de création de paiements Alipay n'est plus prise en charge. Veuillez mettre à niveau votre intégration pour utiliser des sources à la place.",
  "amount_too_large": "Le montant spécifié est supérieur au montant maximum autorisé. Utilisez une quantité inférieure et réessayez.",
  "amount_too_small": "Le montant spécifié est inférieur au montant minimum autorisé. Utilisez une quantité plus élevée et réessayez.",
  "api_key_expired": "La clé API fournie a expiré. Obtenez vos clés API actuelles à partir du tableau de bord et mettez à jour votre intégration pour les utiliser.",
  "balance_insufficient": "Le transfert ou le paiement n'a pas pu être effectué car le compte associé ne dispose pas d'un solde disponible suffisant. Créez un nouveau virement ou paiement en utilisant un montant inférieur ou égal au solde disponible du compte.",
  "bank_account_exists": "Le compte bancaire fourni existe déjà sur l'objet Client spécifié. Si le compte bancaire doit également être associé à un autre client, indiquez le bon numéro de client lors de la nouvelle demande.",
  "bank_account_unusable": "Le compte bancaire fourni ne peut pas être utilisé pour les paiements. Un autre compte bancaire doit être utilisé.",
  "bank_account_unverified": "Votre plateforme Connect tente de partager un compte bancaire non vérifié avec un compte connecté.",
  "bitcoin_upgrade_required": "Cette méthode de création de paiements Bitcoin n'est plus prise en charge. Veuillez mettre à niveau votre intégration pour utiliser des sources à la place.",
  "card_declined": "La carte a été refusée. Lorsqu'une carte est refusée, l'erreur renvoyée inclut également l'attribut déclin_code avec la raison pour laquelle la carte a été refusée. Consultez notre documentation sur les codes de refus pour en savoir plus.",
  "charge_already_captured": "La charge que vous essayez de capturer a déjà été capturée. Mettez à jour la demande avec un ID de facturation non capturé.",
  "charge_already_refunded": "Les frais que vous essayez de rembourser ont déjà été remboursés. Mettez à jour la demande d'utilisation de l'ID d'une charge qui n'a pas été remboursée.",
  "charge_disputed": "Les frais que vous essayez de rembourser ont été remboursés. Consultez la documentation relative aux litiges pour savoir comment réagir au litige.",
  "charge_exceeds_source_limit": "Ces frais vous amèneraient à dépasser votre limite de traitement de la fenêtre glissante pour ce type de source. Veuillez réessayer les frais plus tard ou contactez-nous pour demander une limite de traitement plus élevée.",
  "charge_expired_for_capture": "La charge ne peut pas être capturée car l'autorisation a expiré. Les frais d'authentification et de capture doivent être saisis dans les sept jours.",
  "country_unsupported": "Votre plate-forme a tenté de créer un compte personnalisé dans un pays qui n'est pas encore pris en charge. Assurez-vous que les utilisateurs ne peuvent s'inscrire que dans les pays pris en charge par des comptes personnalisés.",
  "coupon_expired": "Le coupon fourni pour un abonnement ou une commande a expiré. Créez un nouveau coupon ou utilisez-en un existant valide.",
  "customer_max_subscriptions": "Le nombre maximum d'abonnements pour un client a été atteint. Contactez-nous si vous recevez cette erreur.",
  "email_invalid": "L'adresse e-mail n'est pas valide (par exemple, n'est pas correctement formatée). Vérifiez que l'adresse e-mail est correctement formatée et ne comprend que les caractères autorisés.",
  "expired_card": "La carte a expiré. Vérifiez la date d'expiration ou utilisez une autre carte.",
  "idempotency_key_in_use": "La clé d'idempotence fournie est actuellement utilisée dans une autre demande. Cela se produit si votre intégration effectue des demandes en double simultanément.",
  "incorrect_address": "L’adresse de la carte est incorrecte. Vérifiez l’adresse de la carte ou utilisez une autre carte.",
  "incorrect_cvc": "Le code de sécurité de la carte est incorrect. Vérifiez le code de sécurité de la carte ou utilisez une autre carte.",
  "incorrect_number": "Le numéro de carte est incorrect. Vérifiez le numéro de la carte ou utilisez une autre carte.",
  "incorrect_zip": "Le code postal de la carte est incorrect. Vérifiez le code postal de la carte ou utilisez une autre carte.",
  "instant_payouts_unsupported": "La carte de débit fournie en tant que compte externe ne prend pas en charge les paiements instantanés. Fournissez une autre carte de débit ou utilisez un compte bancaire à la place.",
  "invalid_card_type": "La carte fournie en tant que compte externe n'est pas une carte de débit. Fournissez une carte de débit ou utilisez plutôt un compte bancaire.",
  "invalid_charge_amount": "Le montant spécifié n'est pas valide. Le montant des frais doit être un entier positif dans la plus petite unité monétaire et ne pas dépasser le montant minimum ou maximum.",
  "invalid_cvc": "Le code de sécurité de la carte n’est pas valide. Vérifiez le code de sécurité de la carte ou utilisez une autre carte.",
  "invalid_expiry_month": "Le mois d'expiration de la carte est incorrect. Vérifiez la date d'expiration ou utilisez une autre carte.",
  "invalid_expiry_year": "L’année d’expiration de la carte est incorrecte. Vérifiez la date d'expiration ou utilisez une autre carte.",
  "invalid_number": "Le numéro de carte n'est pas valide. Vérifiez les détails de la carte ou utilisez une autre carte.",
  "invalid_source_usage": "La source ne peut pas être utilisée car elle n'est pas dans l'état correct (par exemple, une demande de facturation tente d'utiliser une source avec une source en attente, en échec ou consommée). Vérifiez l'état de la source que vous essayez d'utiliser.",
  "invoice_no_customer_line_items": "Une facture ne peut pas être générée pour le client spécifié car il n'y a aucun poste de facture en attente. Vérifiez que le bon client est spécifié ou créez d'abord les éléments de facture nécessaires.",
  "invoice_no_subscription_line_items": "Une facture ne peut pas être générée pour l'abonnement spécifié car il n'y a aucun élément de facture en attente. Vérifiez que l'abonnement correct est spécifié ou créez d'abord les éléments de facture nécessaires.",
  "invoice_not_editable": "La facture spécifiée ne peut plus être modifiée. Au lieu de cela, envisagez de créer des éléments de facture supplémentaires qui seront appliqués à la prochaine facture. Vous pouvez soit générer manuellement la prochaine facture, soit attendre qu'elle soit générée automatiquement à la fin du cycle de facturation.",
  "invoice_upcoming_none": "Il n'y a pas de facture à venir sur le client spécifié à prévisualiser. Seuls les clients avec des abonnements actifs ou des éléments de facture en attente ont des factures qui peuvent être prévisualisées.",
  "livemode_mismatch": "Les clés d'API, les requêtes et les objets en mode test et en direct ne sont disponibles que dans le mode dans lequel ils se trouvent.",
  "missing": "Un client et un identifiant source ont été fournis, mais la source n'a pas été enregistrée pour le client. Pour créer des frais pour un client avec une source spécifiée, vous devez d'abord enregistrer les détails de la carte.",
  "not_allowed_on_standard_account": "Les transferts et paiements au nom d'un compte connecté Standard ne sont pas autorisés.",
  "order_creation_failed": "La commande n'a pas pu être créée. Vérifiez les détails de la commande, puis réessayez.",
  "order_required_settings": "La commande n'a pas pu être traitée car il manque les informations requises. Vérifiez les informations fournies et réessayez.",
  "order_status_invalid": "La commande ne peut pas être mise à jour car le statut fourni est soit invalide, soit ne suit pas le cycle de vie de la commande (par exemple, une commande ne peut pas passer de créée à exécutée sans passer d'abord à payée).",
  "order_upstream_timeout": "La demande a expiré. Réessayez plus tard.",
  "out_of_inventory": "Le SKU est en rupture de stock. Si plus de stock est disponible, mettez à jour la quantité d'inventaire du SKU et réessayez.",
  "parameter_invalid_empty": "Une ou plusieurs valeurs obligatoires n'ont pas été fournies. Assurez-vous que les demandes incluent tous les paramètres requis.",
  "parameter_invalid_integer": "Un ou plusieurs paramètres nécessitent un entier, mais les valeurs fournies étaient d'un type différent. Assurez-vous que seules les valeurs prises en charge sont fournies pour chaque attribut.",
  "parameter_invalid_string_blank": "Une ou plusieurs valeurs fournies incluaient uniquement des espaces. Vérifiez les valeurs de votre demande et mettez à jour celles qui ne contiennent que des espaces.",
  "parameter_invalid_string_empty": "Une ou plusieurs valeurs de chaîne obligatoires sont vides. Assurez-vous que les valeurs de chaîne contiennent au moins un caractère.",
  "parameter_missing": "Une ou plusieurs valeurs obligatoires sont manquantes.",
  "parameter_unknown": "La demande contient un ou plusieurs paramètres inattendus. Supprimes-les et réessayes.",
  "parameters_exclusive": "Au moins deux paramètres mutuellement exclusifs ont été fournis.",
  "payment_intent_authentication_failure": "L'authentification de la source fournie a échoué. Fournissez source_data ou une nouvelle source pour tenter de remplir à nouveau ce PaymentIntent.",
  "payment_intent_incompatible_payment_method": "PaymentIntent s'attendait à un mode de paiement avec des propriétés différentes de celles fournies.",
  "payment_intent_invalid_parameter": "Un ou plusieurs paramètres fournis n'étaient pas autorisés pour l'opération donnée sur PaymentIntent. Consultez notre référence API ou le message d'erreur renvoyé pour voir quelles valeurs n'étaient pas correctes pour ce PaymentIntent.",
  "payment_intent_payment_attempt_failed": "La dernière tentative de paiement pour PaymentIntent a échoué. Vérifiez la propriété last_payment_error sur le PaymentIntent pour plus de détails, et indiquez source_data ou une nouvelle source pour tenter à nouveau de remplir ce PaymentIntent.",
  "payment_intent_unexpected_state": "L'état de PaymentIntent était incompatible avec l'opération que vous tentiez d'effectuer.",
  "payment_method_unactivated": "Les frais ne peuvent pas être créés car le mode de paiement utilisé n'a pas été activé. Activez le mode de paiement dans le tableau de bord, puis réessayez.",
  "payment_method_unexpected_state": "L'état du mode de paiement fourni était incompatible avec l'opération que vous tentiez d'effectuer. Vérifiez que le mode de paiement est dans un état autorisé pour l'opération donnée avant de tenter de l'exécuter.",
  "payouts_not_allowed": "Les paiements ont été désactivés sur le compte connecté. Vérifiez l'état du compte connecté pour voir si des informations supplémentaires doivent être fournies ou si les paiements ont été désactivés pour une autre raison.",
  "platform_api_key_expired": "La clé API fournie par votre plateforme Connect a expiré. Cela se produit si votre plateforme a généré une nouvelle clé ou si le compte connecté a été déconnecté de la plateforme. Obtenez vos clés API actuelles à partir du tableau de bord et mettez à jour votre intégration, ou contactez l'utilisateur et reconnectez le compte.",
  "postal_code_invalid": "Le code postal fourni était incorrect.",
  "processing_error": "Une erreur s'est produite lors du traitement de la carte. Vérifiez que les détails de la carte sont corrects ou utilisez une autre carte.",
  "product_inactive": "Le produit auquel ce SKU appartient n'est plus disponible à l'achat.",
  "rate_limit": "Trop de demandes atteignent l'API trop rapidement. Nous recommandons un délai exponentiel de vos demandes.",
  "resource_already_exists": "Une ressource avec un ID spécifié par l'utilisateur (par exemple, plan ou coupon) existe déjà. Utilisez une valeur différente et unique pour id et réessayez.",
  "resource_missing": "L'identifiant fourni n'est pas valide. Soit la ressource n'existe pas, soit un ID pour une ressource différente a été fourni.",
  "routing_number_invalid": "Le numéro d'acheminement bancaire fourni n'est pas valide.",
  "secret_key_required": "La clé API fournie est une clé publiable, mais une clé secrète est requise. Obtenez vos clés API actuelles à partir du tableau de bord et mettez à jour votre intégration pour les utiliser.",
  "sepa_unsupported_account": "Votre compte ne prend pas en charge les paiements SEPA.",
  "shipping_calculation_failed": "Le calcul de l'expédition a échoué car les informations fournies étaient incorrectes ou n'ont pas pu être vérifiées.",
  "sku_inactive": "Le SKU est inactif et n'est plus disponible à l'achat. Utilisez un SKU différent ou réactivez le SKU actuel.",
  "state_unsupported": "Se produit lors de la fourniture des informations legal_entity pour un compte personnalisé américain, si l'état fourni n'est pas pris en charge. (Il s'agit principalement d'états et de territoires associés.)",
  "tax_id_invalid": "Le numéro d'identification fiscale fourni n'est pas valide (par exemple, des chiffres manquants). Les informations d'identification fiscale varient d'un pays à l'autre, mais doivent comporter au moins neuf chiffres.",
  "taxes_calculation_failed": "Le calcul de la taxe pour la commande a échoué.",
  "testmode_charges_only": "Votre compte n'a pas été activé et ne peut effectuer que des frais de test. Activez votre compte dans le tableau de bord pour commencer à traiter les frais réels.",
  "tls_version_unsupported": "Votre intégration utilise une ancienne version de TLS qui n'est pas prise en charge. Vous devez utiliser TLS 1.2 ou supérieur.",
  "token_already_used": "Le jeton fourni a déjà été utilisé. Vous devez créer un nouveau jeton avant de pouvoir réessayer cette demande.",
  "token_in_use": "Le jeton fourni est actuellement utilisé dans une autre demande. Cela se produit si votre intégration effectue des demandes en double simultanément.",
  "transfers_not_allowed": "Le transfert demandé ne peut pas être créé. Contactez-nous si vous recevez cette erreur.",
  "upstream_order_creation_failed": "La commande n'a pas pu être créée. Vérifiez les détails de la commande, puis réessayez.",
  "url_invalid": "L'URL fournie n'est pas valide."
};

var error_messages = {
  "Must be at least 13 years of age to use Stripe": "Tu dois avoir l'âge de 13 ans minimum."
};

Map<String,dynamic> required_fields = {
  "business_profile.mcc":["Code APE ou NAF","Cette condition ne peut pas être décochée !","Ton code APE ou NAF doit obligatoirement correspondre au 8299. Si tel n'est pas le cas, contactes ton CFE pour procéder à la modification !","Mon code est bien le ","8299"],
  "business_profile.url":"", //HardCoded value
  "business_type":"", //HardCoded value
  "address":["Adresse de ton auto-entreprise"], //Added just for compliance form title name
  "company.address.city":["VILLE"],
  "company.address.line1":["NUMERO DE RUE/VOIE","NOM DE RUE/VOIE"],
  "company.address.postal_code":["CODE POSTAL"],
  "company.address.state":"",//TODO:To be configured (for countries different than FRANCE)
  "company.name":["Dénomination/Raison sociale","DENOMINATION OU RAISON SOCIALE"],
  "company.owners_provided":"",//HardCoded value
  "company.phone":["Numéro de téléphone (ton auto-entreprise)","TELEPHONE"],
  "company.tax_id":["Ton numéro SIREN","SIREN"],
  "company.verification.document":["Extrait KBIS", "Aucun fichier ajouté"],
  "external_account":["Ton IBAN (Coordonnées bancaires)","IBAN"],
  "owners.address.city":"",//TODO:To be configured
  "owners.address.line1":"",//TODO:To be configured
  "owners.address.postal_code":"",//TODO:To be configured
  "owners.address.state":"",//TODO:To be configured
  "owners.dob.day":"",//TODO:To be configured
  "owners.dob.month":"",//TODO:To be configured
  "owners.dob.year":"",//TODO:To be configured
  "owners.email":"",//TODO:To be configured
  "owners.first_name":"",//TODO:To be configured
  "owners.id_number":"",//TODO:To be configured
  "owners.last_name":"",//TODO:To be configured
  "owners.phone":"",//TODO:To be configured
  "owners.ssn_last_4":"",//TODO:To be configured
  "owners.verification.document":"",//TODO:To be configured
  "representative.address.city":"",//TODO:To be configured
  "representative.address.line1":"",//TODO:To be configured
  "representative.address.postal_code":"",//TODO:To be configured
  "representative.address.state":"",//TODO:To be configured
  "representative.dob.day":"",//TODO:To be configured
  "representative.dob.month":"",//TODO:To be configured
  "representative.dob.year":"",//TODO:To be configured
  "representative.email":"",//TODO:To be configured
  "representative.first_name":"",//TODO:To be configured
  "representative.id_number":"",//TODO:To be configured
  "representative.last_name":"",//TODO:To be configured
  "representative.phone":"",//TODO:To be configured
  "representative.relationship.executive":"",//TODO:To be configured
  "representative.relationship.title":"",//TODO:To be configured
  "representative.ssn_last_4":"",//TODO:To be configured
  "representative.verification.document":"",//TODO:To be configured
  "tos_acceptance.date":"", //HardCoded value
  "tos_acceptance.ip":"", //HardCoded value
};

Map<String,dynamic> person_required_fields = {
  "first_name":["Ton prénom","Ton prénom ne semble pas être correct ! Rends-toi dans la rubrique 'Mon compte' et vérifies si le prénom est juste ou pas. Il doit absolument correspondre avec le prenom établi sur les documents fournis (carte d'identité, etc...)"],
  "last_name":["Ton nom","Ton nom de famille ne semble pas être correct ! Rends-toi dans la rubrique 'Mon compte' et vérifies si le nom de famille est juste ou pas. Il doit absolument correspondre avec le prenom établi sur les documents fournis (carte d'identité, etc...)"],
  "document":["Ta carte d'identité","RECTO","VERSO"],
  "additional_document":["Justificatif de domicile","Exemple: facture de téléphone, d'électricité, etc..."],
  "phone":["Ton numéro téléphone portable utilisé pour le remplir formulaire correspond au numéro de l'appareil actuel."],
  "email":["Ton Email","EMAIL"],
  "account_number":["Ton IBAN (Coordonnées bancaires)","IBAN"],
  "address":["Ton adresse"],
  "address_city":["VILLE"],
  "address_line1":["NUMERO DE RUE/VOIE","NOM DE RUE/VOIE"],
  "address_postal_code":["CODE POSTAL"],
  "dob":["Ta date de naissance","Jour","Mois","Année"],
};

const g_monthNames = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
];

const g_countriesAvailabilityForAppFilters = ["FR", "BE", "LU", "CH","DZ", "BF", "BJ", "CM", "CD", "CG","CI", "GA", "GN", "GW", "MA","NE","SN","TG","TN","ML"];

Map<String,dynamic> g_africanCountriesCurrencies = {
  "DZ":["dzd","دج","price_1NqzJSFgbU2VtDqv62bkYdGE"],
  "BF":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "BJ":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "CM":["xaf","FCFA","price_1NqzSCFgbU2VtDqv4cjvLWqo"],
  "CD":["cdf","F","price_1NqzZ6FgbU2VtDqvHG6XoQ09"],
  "CG":["xaf","FCFA","price_1NqzSCFgbU2VtDqv4cjvLWqo"],
  "CI":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "GA":["xaf","FCFA","price_1NqzSCFgbU2VtDqv4cjvLWqo"],
  "GN":["gnf","FG","price_1NqzauFgbU2VtDqvgCaD0uVu"],
  "GW":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "MA":["mad","د.إ","price_1NqzXGFgbU2VtDqvv8HmAZw7"],
  "NE":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "SN":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "TG":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
  "TN":["eur","€","price_1NqzeIFgbU2VtDqvJeUqxMdG"],
  "ML":["xof","CFA","price_1NqzN3FgbU2VtDqvXsixu8M9"],
};

Map<String,dynamic> g_europeCountriesCurrencies = {
  "FR":["eur","€","price_1N0i8YFgbU2VtDqvQcL5SW5P"],
  "BE":["eur","€","price_1N0i8YFgbU2VtDqvQcL5SW5P"],
  "LU":["eur","€","price_1N0i8YFgbU2VtDqvQcL5SW5P"],
  "CH":["chf","CHF","price_1Nqzi6FgbU2VtDqvsZQVOIpg"],
};

Map<String,dynamic> g_countriesGeoLocalization = {
  "FR":["FR","BE","LU","CH","DZ","MA","TN","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "BE":["BE","FR","LU","CH","DZ","MA","TN","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "LU":["LU","FR","BE","CH","DZ","MA","TN","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "CH":["CH","FR","LU","BE","DZ","MA","TN","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "DZ":["DZ","MA","TN","FR","CH","LU","BE","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "BF":["BF","TG","ML","BJ","NE","CI","GW","GN","SN","CM","GA","CG","CD","MA","DZ","TN","FR","CH","LU","BE"],
  "BJ":["BJ","TG","BF","ML","NE","CI","CM","GW","GN","SN","GA","CG","CD","MA","DZ","TN","FR","CH","LU","BE"],
  "CM":["CM","GA","CG","CD","BJ","TG","BF","ML","NE","CI","GW","GN","SN","MA","DZ","TN","FR","CH","LU","BE"],
  "CD":["CD","GA","CG","CM","BJ","TG","BF","ML","NE","CI","GW","GN","SN","MA","DZ","TN","FR","CH","LU","BE"],
  "CG":["CG","GA","CD","CM","BJ","TG","BF","ML","NE","CI","GW","GN","SN","MA","DZ","TN","FR","CH","LU","BE"],
  "CI":["CI","TG","BJ","BF","ML","NE","GA","CG","CD","CM","GW","GN","SN","MA","DZ","TN","FR","CH","LU","BE"],
  "GA":["GA","CG","CD","CM","BJ","TG","BF","ML","NE","CI","GW","GN","SN","MA","DZ","TN","FR","CH","LU","BE"],
  "GN":["GN","SN","CI","GW","TG","BJ","BF","ML","NE","GA","CG","CD","CM","MA","DZ","TN","FR","CH","LU","BE"],
  "GW":["GW","SN","CI","GN","TG","BJ","BF","ML","NE","GA","CG","CD","CM","MA","DZ","TN","FR","CH","LU","BE"],
  "MA":["MA","DZ","TN","FR","CH","LU","BE","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "NE":["NE","BF","ML","BJ","TG","CM","CI","SN","GW","GN","GA","CG","CD","DZ","MA","TN","FR","CH","LU","BE"],
  "SN":["SN","GW","GN","ML","CI","BF","TG","BJ","NE","CM","GA","CG","CD","DZ","MA","TN","FR","CH","LU","BE"],
  "TG":["TG","BJ","BF","ML","NE","CI","CM","GW","GN","SN","GA","CG","CD","MA","DZ","TN","FR","CH","LU","BE"],
  "TN":["TN","DZ","MA","FR","CH","LU","BE","ML","NE","SN","BF","GW","GN","CI","TG","BJ","CM","GA","CG","CD"],
  "ML":["ML","BF","NE","CI","SN","GW","GN","TG","BJ","CM","GA","CG","CD","DZ","MA","TN","FR","CH","LU","BE"],
};

Map<String,dynamic> g_helperSpotPriceCurrencies = {
  "FR":["eur","€",10,50,"2.50","10","1000","France"],
  "BE":["eur","€",10,50,"2.50","10","1000","Belgique"],
  "LU":["eur","€",10,50,"2.50","10","1000","Luxembourg"],
  "CH":["chf","CHF",10,50,"2.40","9.60","960","Suisse"],
  "DZ":["dzd","دج",1000,1700,"370","1465","37000","Algérie"],
  "BF":["xof","CFA",3950,6600,"1640","6557","164000","Burkina Faso"],
  "BJ":["xof","CFA",3950,6600,"1640","6557","164000","Bénin"],
  "CM":["xaf","FCFA",3950,6600,"1640","6557","164000","Cameroun"],
  "CD":["cdf","F",16000,28000,"6640","26550","664000","République démocratique\ndu Congo"],
  "CG":["xaf","FCFA",3950,6600,"1640","6557","164000","Congo"],
  "CI":["xof","CFA",3950,6600,"1640","6557","164000","Côte d'Ivoire"],
  "GA":["xaf","FCFA",3950,6600,"1640","6557","164000","Gabon"],
  "GN":["gnf","FG",61300,107000,"22958","91829","2295800","Guinée"],
  "GW":["xof","CFA",3950,6600,"1640","6557","164000","Guinée-Bissau"],
  "MA":["mad","د.إ",74,128,"27.90","109.90","2790","Maroc"],
  "NE":["xof","CFA",3950,6600,"1640","6557","164000","Niger"],
  "SN":["xof","CFA",3950,6600,"1640","6557","164000","Sénégal"],
  "TG":["xof","CFA",3950,6600,"1640","6557","164000","Togo"],
  "TN":["eur","€",6,12,"2.50","10","25","Tunisie"],
  "ML":["xof","CFA",3950,6600,"1640","6557","164000","Mali"],
};

Map<String,dynamic> g_countriesCurrenciesRates = {
  "FR":1,
  "BE":1,
  "LU":1,
  "CH":0.95,
  "DZ":148,
  "BF":660,
  "BJ":660,
  "CM":660,
  "CD":2645,
  "CG":660,
  "CI":660,
  "GA":660,
  "GN":9148,
  "GW":660,
  "MA":12,
  "NE":660,
  "SN":660,
  "TG":660,
  "TN":3.50,
  "ML":660,
};
