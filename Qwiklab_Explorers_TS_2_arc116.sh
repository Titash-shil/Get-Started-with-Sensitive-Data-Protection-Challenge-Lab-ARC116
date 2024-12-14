cat > job-configuration.json << EOM
{
  "triggerId": "dlp_job",
  "jobTrigger": {
    "triggers": [
      {
        "schedule": {
          "recurrencePeriodDuration": "604800s"
        }
      }
    ],
    "inspectJob": {
      "actions": [
        {
          "deidentify": {
            "fileTypesToTransform": [
              "TEXT_FILE",
              "IMAGE",
              "CSV",
              "TSV"
            ],
            "transformationDetailsStorageConfig": {},
            "transformationConfig": {
              "deidentifyTemplate": "projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates/unstructured_data_template",
              "structuredDeidentifyTemplate": "projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates/structured_data_template"
            },
            "cloudStorageOutput": "gs://$DEVSHELL_PROJECT_ID-output"
          }
        }
      ],
      "inspectConfig": {
        "infoTypes": [
          {
            "name": "ADVERTISING_ID"
          },
          {
            "name": "AGE"
          },
          {
            "name": "ARGENTINA_DNI_NUMBER"
          },
          {
            "name": "AUSTRALIA_TAX_FILE_NUMBER"
          },
          {
            "name": "BELGIUM_NATIONAL_ID_CARD_NUMBER"
          },
          {
          },
          {
            "name": "UK_NATIONAL_HEALTH_SERVICE_NUMBER"
          },
          {
            "name": "UK_NATIONAL_INSURANCE_NUMBER"
          },
          {
            "name": "UK_TAXPAYER_REFERENCE"
          },
          {
            "name": "URUGUAY_CDI_NUMBER"
          },
          {
            "name": "US_BANK_ROUTING_MICR"
          },
          {
            "name": "US_EMPLOYER_IDENTIFICATION_NUMBER"
          },
          {
            "name": "US_HEALTHCARE_NPI"
          },
          {
            "name": "US_INDIVIDUAL_TAXPAYER_IDENTIFICATION_NUMBER"
          },
          {
            "name": "US_SOCIAL_SECURITY_NUMBER"
          },
          {
            "name": "VEHICLE_IDENTIFICATION_NUMBER"
          },
          {
            "name": "VENEZUELA_CDI_NUMBER"
          },
          {
            "name": "WEAK_PASSWORD_HASH"
          },
          {
            "name": "AUTH_TOKEN"
          },
          {
            "name": "AWS_CREDENTIALS"
          },
          {
            "name": "AZURE_AUTH_TOKEN"
          },
          {
            "name": "BASIC_AUTH_HEADER"
          },
          {
            "name": "ENCRYPTION_KEY"
          },
          {
            "name": "GCP_API_KEY"
          },
          {
            "name": "GCP_CREDENTIALS"
          },
          {
            "name": "JSON_WEB_TOKEN"
          },
          {
            "name": "HTTP_COOKIE"
          },
          {
            "name": "XSRF_TOKEN"
          }
        ],
        "minLikelihood": "POSSIBLE"
      },
      "storageConfig": {
        "cloudStorageOptions": {
          "filesLimitPercent": 100,
          "fileTypes": [
            "TEXT_FILE",
            "IMAGE",
            "WORD",
            "PDF",
            "AVRO",
            "CSV",
            "TSV",
            "EXCEL",
            "POWERPOINT"
          ],
          "fileSet": {
            "regexFileSet": {
              "bucketName": "$DEVSHELL_PROJECT_ID-input",
              "includeRegex": [],
              "excludeRegex": []
            }
          }
        }
      }
    },
    "status": "HEALTHY"
  }
}
EOM

# Step 2: Send job configuration to DLP API
echo -e "${YELLOW}${BOLD}Sending job configuration to DLP API...${RESET}"

curl -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/global/jobTriggers \
-d @job-configuration.json

# Step 3: Wait for job trigger activation
echo -e "${BLUE}${BOLD}Waiting 15 seconds before activating the job trigger...${RESET}"

sleep 15

# Step 4: Activate the job trigger
echo -e "${GREEN}${BOLD}Activating the job trigger...${RESET}"

curl --request POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "X-Goog-User-Project: $DEVSHELL_PROJECT_ID" \
  "https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/global/jobTriggers/dlp_job:activate"
