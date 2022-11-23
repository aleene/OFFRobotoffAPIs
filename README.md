#  OFFRobotoffAPIs

This is an demonstration app for the various Folksonomy API's of Open Food Facts.

## Robotoff
Robotoff provides a simple API allowing consumers to fetch predictions and annotate them. Robotoff can interact with all Openfoodfacts products: Openfoodfacts, Openbeautyfacts, etc. and all environments (production, development, pro).

## Demo
The demo application allows you to see the results of API-calls.

## Installation
You can reuse the libraries from this repository. The steps:
- OFF-folder - all the files in this folder should copied.
- RBTF-folder - copy only the files for the API's that you are going to use.

## Usage
### Initialisation

### Product API.

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

## Errors

## Testing

## To Be Done

## Requirements
The demo application has been tested under:
- Xcode version 13.4.1
- Swift version 15.0

## Documentation
- ReDoc: https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/openfoodfacts/robotoff/master/doc/references/api.yml
