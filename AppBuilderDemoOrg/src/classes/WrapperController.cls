public with sharing class WrapperController {
	public WrapperBin wrapObj {get; set;}
	
	public WrapperController() {
		wrapObj = new WrapperBin();
	}
	
	public void renderContactSection() {
		wrapObj.isContactSectionVisible = true;
	}
	
	public void renderOpportunitySection() {
		wrapObj.isOppSectionVisible = true;
	}
	
	public void renderSubmitSection() {
		wrapObj.isSubmitVisible = true;
	}
	
	public void submitRecords() {
		
	}
	
	public class WrapperBin {
		public Account accObj {get; set;}
		public Contact conObj {get; set;}
		public Opportunity oppObj {get; set;}
		public Boolean isContactSectionVisible {get; set;}
		public Boolean isOppSectionVisible {get; set;}
		public Boolean isSubmitVisible {get; set;}
		
		public WrapperBin() {
			accObj = new Account();
			conObj = new Contact();
			oppObj = new Opportunity();	
			isContactSectionVisible = false;
			isOppSectionVisible = false;
			isSubmitVisible = false;	
			
		}
	}
}