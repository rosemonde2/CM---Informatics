with DEN ([Unique Total Patients]) as
(
		SELECT CAST(Count(Distinct OP.Person_ID)as Float) as 'Unique Total Patients' 
		FROM Person OP
)

--Domain Demographics Unique Patients
	SELECT 'Demo Unique Patients' AS 'Domain', '' as 'Patients with Standards', 
	DEN.[Unique Total Patients] as 'Unique Total Patients' ,'' as  '% Standards', 'Not Applicable' as 'Values Present'		
	FROM DEN	

Union
-- Domain Gender
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ DEN.[Unique Total Patients])) as '% Standards','Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Demo Gender' AS Domain, 
		CAST(COUNT(DISTINCT D.person_id) as Float) AS 'Patients with Standards'
		FROM Person D
		INNER JOIN Concept C ON D.Gender_concept_id = C.concept_id AND C.vocabulary_id = 'Gender' 
		) Num, DEN

Union
-- Domain Age/DOB
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards','Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Demo Age/DOB' AS Domain, 
		CAST(COUNT(DISTINCT D.person_id) as Float) AS 'Patients with Standards'
		FROM Person D
		-- We may want to alter this to be only Year of birth present at this time Year, Month and day are required in order to counts
		Where D.birth_datetime  is NOT NULL 
			--Where D.Year_of_Birth  is NOT NULL 
			--nd  D.month_of_Birth is NOT NULL 
			--and  D.Day_of_Birth  is NOT NULL
		) Num, DEN

Union
-- Domain Labs
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards' , 'Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Labs as LOINC' AS Domain, 
		CAST(COUNT(DISTINCT D.person_id) as Float) AS 'Patients with Standards'
		FROM Measurement D
		JOIN Concept C ON D.Measurement_concept_id = C.concept_id AND C.vocabulary_id = 'LOINC' 
		) Num, DEN

Union
-- Domain Drug
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards','Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Drugs as RxNORM' AS Domain, 
		CAST(COUNT(DISTINCT D.person_id) as Float) AS 'Patients with Standards'
		FROM DRUG_EXPOSURE D
		JOIN Concept C ON D.drug_concept_id = C.concept_id AND C.vocabulary_id = 'RxNorm' 
		) Num, DEN
Union
-- Domain Condition
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards', 'Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Diagnosis as ICD/SNOMED' AS Domain, 
		CAST(COUNT(DISTINCT P.person_id) as Float) AS 'Patients with Standards' 
		FROM [Condition_Occurrence] P
		LEFT JOIN Concept c ON p.condition_source_concept_id = c.concept_id AND c.vocabulary_id IN ('SNOMED','ICD9CM','ICD10CM')
		LEFT JOIN Concept c2 ON p.condition_concept_id = c2.concept_id AND c2.vocabulary_id IN ('SNOMED','ICD9CM','ICD10CM')
		WHERE c.concept_id IS NOT NULL OR c2.concept_id IS NOT NULL
		) Num, DEN

Union
-- Domain Procedure
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards', 'Not Applicable' as 'Values Present'		
	From 
		(
		SELECT 'Procedures as ICD/SNOMED/CPT4' AS Domain, 
		CAST(COUNT(DISTINCT P.person_id) as Float) AS 'Patients with Standards'
		FROM procedure_occurrence P
		LEFT JOIN Concept c ON p.procedure_source_concept_id= c.concept_id AND c.vocabulary_id IN ('SNOMED','ICD9Proc','ICD10PCS','CPT4')
		LEFT JOIN Concept c2 ON p.procedure_concept_id = c2.concept_id   AND c2.vocabulary_id IN ('SNOMED','ICD9Proc','ICD10PCS','CPT4')
		WHERE c.concept_id IS NOT NULL OR c2.concept_id IS NOT NULL
		) Num, DEN

Union
-- Domain Observatins are a yes or no on whether they exist or not
	Select 'Observations Present' AS 'Domain',  '' as 'Patients with Standards', '' as 'Unique Total Patients', '' as  '% Standards', 
		Case 
			When Count(*) = 0 then 'No Observation' else 'Observations Present' end as 'Values Present'		
	from observation

Union
-- Domain Note Text
-- This needs to be checked by George H
	Select NUM.*, DEN.*, (100.0 * (NUM.[Patients with Standards]/ Den.[Unique Total Patients])) as '% Standards','Not Applicable' as 'Values Present'	
	From 
		(
		SELECT 'Note Text' AS Domain, 
		CAST(COUNT(DISTINCT D.person_id) as Float) AS 'Patients with Standards'
		FROM Note D
		) Num, DEN

----Union
---- Domain NLP present does not measure % of unique patients
--	--Select 'Note NLP Present' AS 'Domain',  '' as 'Patients with Standards', '' as 'Unique Total Patients', '' as  '% Standards', 
--	--	Case 
--	--		When Count(*) = 0 then 'No Observation' else 'Observations Present' end as 'Values Present'		
--	--from Note_NLP

Order by Domain