#  OFFRobotoffAPIs

This is an demonstration app for the various Folksonomy API's of Open Food Facts.

## Robotoff
Robotoff provides a simple API allowing consumers to fetch predictions and annotate them. Robotoff can interact with all Openfoodfacts products: Openfoodfacts, Openbeautyfacts, etc. and all environments (production, development, pro).

## Demo
The demo application allows you to see the implementation and the raw results of API-calls.

## Installation
You can reuse the libraries from this repository. For reuse you need one or more folders from the folder Robotoff.

The steps:
- Required-folder - all the files in this folder are required and should copied;
- Basic-folder - you can copy only the files for the endpoints that you are going to use. (or just copy everything) These files only use basic types (Strings, UInt), so you have to figure out the required input for the API-calls yourself. However for the ouput (received jsons), you do need the defined types;
- Extended-folder - this folder contains implementations that make used of higher level structures for languages, countries, annotation, insight types, etc. These implementations are preferred as they limit the possible errors

## Usage
### Aproach
The usage of each endpoint is the similar:
 1 setup the session, like `rbtfSession = URLSession.shared`
 2 call the API, like `rbtfSession.RBTFcall()`
 3 process the result on the main queue like
```
switch result {
case .success(let response):
    self.response = response
case .failure(let error):
    self.errorMessage = error.description
}
```

### Product endpoint.

Function which retrieves the possible questions for a specific product.
```
func RBTFQuestionsProduct(with barcode: OFFBarcode, count: Int?, lang: String?, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void)
```
**Parameters**
- offbarcode: the OFFBarcode for the product;
- count: the maximum numer of questions to be retrived for this product. If not specified the value is 1;
- lang: the language code for the question and possible answer. If not specified en is assumed (english);

**Returns**
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.

### Unanswered questions endpoint
Function to retrieve a random product wth a question with a list of query parameters to filter the questions
```
func RBTFUnAnsweredQuestionsExtensionCount(count: UInt?, insightType: RBTF.InsightType?, country: Country?, page: UInt?, completion: @escaping (_ result: Result<RBTF.UnansweredQuestionsResponse, RBTFError>) -> Void)
```
or without enumerated types
```
func RBTFUnAnsweredQuestionsCount(count: UInt?, insightType: String?, country: String?, page: UInt?, completion: @escaping (_ result: Result<RBTF.UnansweredQuestionsResponse, RBTFError>) -> Void)

```
**Parameters**
- count: the number of questions to return (default=1)
- insightType: filter by insight type (i.e. InsightType.brand or "brand")
- country: filter by country tag (i.e. Country.france or "en:france"")
- page: page index to return (starting at 1), default=1

**Returns**
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
Not all possible query parameters have been implemented, as they are not useful to everyone (server_domain, reserved_barcode, campaign, predictor).


### Insights random API
Function to retrieve a random insights with a list of query parameters to filter the questions
Declaration
```
func RBTFInsights(insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void)
```
Not all possible query parameters have been implemented, as they are not useful to everyone (server_domain, campaign, predictor).
** Parameters **
- insightType: filter by insight type
- country: filter by country tag
- valueTag:filter by value tag
- count: the number of questions to return (default=1
** Returns **
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.

### Insights barcode API
Function to retrieve a random insights with a list of query parameters to filter the questions
Declaration
```
func RBTFInsights(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void)
```
** Parameters **
- barcode: barcode for which this insights are sought (required)
- insightType: filter by insight type
- country: filter by country tag
- valueTag: filter by value tag count: the number of questions to return (default=1

Not all possible query parameters have been implemented, as they are not useful to everyone (server_domain, campaign, predictor).
** Returns **
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.

### Insights detail API
Function to retrieve the details of a specific insight
```
func RBTFInsights(insightId: String, completion: @escaping (_ result: Result<RBTF.Insight, RBTFError>) -> Void)
```
** Parameters **
- insightId: the id of an insight
** Returns **
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.

### Predict category API
Function to predict categories for a product

```
func RBTFPredictCategoriesProduct(barcode: OFFBarcode, deepestOnly: Bool?, threshold: Double?, predictors: [RBTF.Predictors]?, completion: @escaping (_ result: Result<RBTF.PredictResponse, RBTFError>) -> Void)
```
or without the special enumerator and struct
```
func RBTFPredictCategoriesProduct(barcode: String, deepestOnly: Bool?, threshold: Double?, predictors: [String]?, completion: @escaping (_ result: Result<RBTF.PredictResponse, RBTFError>) -> Void)
```

** Parameters **
- barcode: the barcode of the product to categorize
- deepestOnly: if true, only return the deepest elements in the category taxonomy (don’t return categories that are parents of other predicted categories)
- threshold: default: 0.5; The score above which we consider the category to be detected
- predictors: Array Predictors (Enum): .neural and/or .matcher; List of predictors to use, possible values are matcher (simple matching algorithm) and neural (neural network categorizer)

** Returns **
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.PredictResponse struct and for the failure an Error. An invalid barcode (lenth 0 or not 8,12 or 13 will result in an error)

## Results
The API-calls can produce multiple positive (code 200) results jsons.

### QuestionsResponse json
The results can be either positive (one or more questions), or negative (no questions).

#### Positive result
If the API-call results in one or more questions, the following example json. In this json the **status**-field has the value **found**:
```
{
  "questions": [
    {
      "barcode": "4056489098683",
      "type": "add-binary",
      "value": "Chocolade koekjes",
      "question": "Behoort het product tot deze categorie?",
      "insight_id": "4e11070b-f15c-433a-869c-7e4b3facae25",
      "insight_type": "category",
      "value_tag": "en:chocolate-biscuits",
      "source_image_url": "https://static.openfoodfacts.org/images/products/405/648/909/8683/front_de.33.400.jpg"
    }
  ],
  "status": "found"
}
```
The **questions**-field contains an array of questions, with the following fields for each question:
- barcode: the barcode of the product (String with only numerical fields);
- type: the question type, add-binary is a true/false/skip question;
- value: the possible answer for the question (a user can confirm, abstain or deny) in the language specified in the API-call;
- question: The question that can be presented to the user in the language specified in the API-call;
- insight_id: the id for this question, which must be used as reference for further API-calls;
- insight_type: the subject of the question (in this case the category of the product);
- value_tag: the canonical value of the possible answer in the taxonomy;
- source_image\_url: a link to the image from which the question/insight has been deduced;

#### Negative result
When the API-call does not result in any questions, the following json is returned. In this json the **status**-field has the value **no_questions**::
```
{
  "questions": [
    {}
  ],
  "status": "no_questions"
}
```
### Insight types
The insight type, i.e. the subject the question is about, can have the following values. These values are converted to the enum InsightType
- **brand**: extracts the product's brand from the image OCR.
- **category**: predicts the category of a product.
- **expiration_date**: extracts the expiration date from the image OCR.
- **image_orientation**: predicts the image orientation of the given image.
- **ingredient_spellcheck**: corrects the spelling in the given ingredients list.
- **image_flag**: flags inappropriate images based on OCR text.
- **image_lang**: detects which languages are mentioned on the product from the image OCR.
- **label**: predicts a label that appears on the product packaging photo.
- **location**: the location of where the product comes from from the image OCR.
- **nutrient**: the list of nutrients mentioned in a product, alongside their numeric value from the image OCR.
- **nutrient_mention**: mentions of nutrients from the image OCR (without actual values).
- **nutrition_image**: tags images that have nutrition information based on the 'nutrient_mention' insight and the 'image_orientation' insight.
- **nutrition_table_structure**: detects the nutritional table structure from the image.
- **packaging**: detects the type of packaging based on the image OCR.
- **product_weight**: extracts the product weight from the image OCR.
- **store**: the store where the given product is sold from the image OCR.
- **trace**: detects traces that are present in the product from the image OCR.

### Predict response
```
public struct PredictResponse: Codable {
    var neural: [NeuralResponse]?
    var matcher: [MatcherResponse]?
}
```
```

public struct NeuralResponse: Codable {
    var value_tag: String?
    var confidence: Float?
}
```
```

public struct MatcherResponse: Codable {
    var value_tag: String?
    var debug: MatcherDebug?
}
```
```
public struct MatcherDebug: Codable {
    var pattern: String?
    var lang: String?
    var product_name: String?
    var processed_product_name: String?
    var category_name: String?
    var start_idx: Int?
    var end_idx: Int?
    var is_full_match: Bool?
}
```

## Errors
The implementation has encoded a variety of possible errors, so that these can be intercepted and prevented by the user of this library. Most errors are already intercepted of prevented by the API's:
 - authenticationRequired: the call resulted in error json, which states that a valid authentication should be provided;
 - barcodeInvalid: the barcode has an incorrect length, i.e. is not 8, 12 or 13 digits;
 - connectionFailure: something went wrong. Used for not intercepted errors;
 - dataCorrupted: the json decoder had an issue with the data (not sure when this occurs))
 - errorAnalysis: the error json contains an error that is not intercepted
 - insightUnknown: a 404 when the insight does not exist
 - keyNotFound: a required key when decoding was not found
 - methodNotAllowed: the error json spedified that a method has been supplied that is not existing
 - missingParameter: the url is missing a parameter
 - noBody: no body has been received
 - typeMismatch: the decoder found an unexpected type
 - unsupportedSuccessResponseType: a not intercepted decoding error
 - valueNotFound: the decoder found an unexpected value
 
## Testing
A series of tests have been implemented to test some aspects:
 - the decoding
 - the endpoint URL's
 
## To Be Done
- manu=y more errors could be intercepted
- tests for the network
 
## Requirements
The demo application has been tested under:
- Xcode version 14.1
- Swift version 15.0

## Documentation
- ReDoc: https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/openfoodfacts/robotoff/master/doc/references/api.yml
