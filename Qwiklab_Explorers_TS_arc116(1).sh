cat > redact-request.json <<EOF_END
{
	"item": {
		"value": "Please update my records with the following information:\n Email address: foo@example.com,\nNational Provider Identifier: 1245319599"
	},
	"deidentifyConfig": {
		"infoTypeTransformations": {
			"transformations": [{
				"primitiveTransformation": {
					"replaceWithInfoTypeConfig": {}
				}
			}]
		}
	},
	"inspectConfig": {
		"infoTypes": [{
				"name": "EMAIL_ADDRESS"
			},
			{
				"name": "US_HEALTHCARE_NPI"
			}
		]
	}
}
EOF_END

curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/content:deidentify \
  -d @redact-request.json -o redact-response.txt

# Copy response to Google Cloud Storage
echo -e "${GREEN}${BOLD}Uploading redact-response.txt to Google Cloud Storage...${RESET}"

gsutil cp redact-response.txt gs://$DEVSHELL_PROJECT_ID-redact

cat > template.json <<EOF_END
{
	"deidentifyTemplate": {
	  "deidentifyConfig": {
		"recordTransformations": {
		  "fieldTransformations": [
			{
			  "fields": [
				{
				  "name": "bank name"
				},
				{
				  "name": "zip code"
				}
				
			  ],
			  "primitiveTransformation": {
				"characterMaskConfig": {
				  "maskingCharacter": "#"
				  
				}
				
			  }
			  
			}
			
		  ]
		  
		}
		
	  },
	  "displayName": "structured_data_template"
	  
	},
	"locationId": "global",
	"templateId": "structured_data_template"
  }
EOF_END

# Send template to API
echo -e "${YELLOW}${BOLD}Sending structured_data_template to DLP API...${RESET}"

curl -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/deidentifyTemplates \
-d @template.json

cat > template.json <<'EOF_END'
{
  "deidentifyTemplate": {
    "deidentifyConfig": {
      "infoTypeTransformations": {
        "transformations": [
          {
            "infoTypes": [
              {
                "name": ""
                
              }
              
            ],
            "primitiveTransformation": {
              "replaceConfig": {
                "newValue": {
                  "stringValue": "[redacted]"
                  
                }
              }
              
            }
          }
          
        ]
      }
      
    },
    "displayName": "unstructured_data_template"
    
  },
  "templateId": "unstructured_data_template",
  "locationId": "global"
}
EOF_END

# Send template to API
echo -e "${YELLOW}${BOLD}Sending unstructured_data_template to DLP API...${RESET}"

curl -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/deidentifyTemplates \
-d @template.json

# Output the URLs for the templates
echo -e "${GREEN}${BOLD}Structured Data Template URL:${RESET}"

echo -e "${BLUE}https://console.cloud.google.com/security/sensitive-data-protection/projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates/structured_data_template/edit?project=$DEVSHELL_PROJECT_ID${RESET}"

echo -e "${GREEN}${BOLD}Unstructured Data Template URL:${RESET}"

echo -e "${BLUE}https://console.cloud.google.com/security/sensitive-data-protection/projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates/unstructured_data_template/edit?project=$DEVSHELL_PROJECT_ID${RESET}"
