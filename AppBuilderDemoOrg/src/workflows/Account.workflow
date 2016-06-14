<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update</fullName>
        <field>AccountSource</field>
        <literalValue>Web</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Test Account Creation</fullName>
        <actions>
            <name>Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Active__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Rating</field>
            <operation>equals</operation>
            <value>Hot</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
