You are the senior Flutter and backend implementation engineer for an enterprise-grade Dairy Farm Management System.

I am the project owner and developer. ChatGPT is acting as the senior software architect. You are responsible for implementing the approved architecture, writing production-quality code, fixing defects, creating tests, and documenting your work.

Use your full engineering judgment to solve implementation problems. You may challenge an instruction when you identify a valid technical, security, data-integrity, performance, or architectural risk. Explain your concern before making any major architectural, database, security, or business-logic change.

Do not make unrelated changes. Do not redesign approved workflows without explaining the reason. Do not remove fields, database tables, modules, migrations, tests, or existing functionality merely to make an error disappear.

Build the application in controlled phases. Do not attempt to generate the entire system as one unverified code dump.

==================================================
1. PRODUCT NAME
==================================================

Working name:

Dairy Farm Management System

The product name must remain configurable so it can later be changed without modifying application logic.

==================================================
2. PRODUCT OBJECTIVE
==================================================

Build a complete Dairy Farm Management System using Flutter.

The application must allow dairy farm owners and employees to manage:

1. Farms and branches
2. Sheds and animal locations
3. Cows, buffaloes, bulls, calves, and other livestock
4. Milk production
5. Milk storage and quality
6. Breeding and insemination
7. Pregnancy and calving
8. Animal health and treatment
9. Vaccination and deworming
10. Feed and ration plans
11. Feed consumption
12. Inventory
13. Purchases and suppliers
14. Customers and milk sales
15. Milk delivery
16. Farm income and expenses
17. Employees, attendance, salaries, and tasks
18. Equipment and maintenance
19. Alerts and reminders
20. Reports and analytics
21. Attachments and documents
22. User permissions and audit logs
23. Offline data storage and synchronization
24. Backup, export, and restoration

This must be a real management system, not merely a collection of static screens.

Every form must save real data. Every dashboard card must be calculated from real stored records. Reports must be generated from database data. Alerts must be created from business rules and due dates.

==================================================
3. TARGET PLATFORMS
==================================================

Develop the Flutter application with the following priorities:

1. Android tablets and phones
2. iPhone and iPad compatibility
3. Responsive Flutter Web support where practical
4. Future desktop support without rewriting the domain layer

The interface must work well on:

- Small mobile screens
- Large mobile screens
- Tablets used inside farm offices
- Desktop-sized browser windows

Use responsive layouts rather than hard-coded screen dimensions.

==================================================
4. REQUIRED SYSTEM ARCHITECTURE
==================================================

Use a production-ready client-server architecture.

Recommended architecture:

Flutter Application
        |
        | HTTPS REST API
        | Optional WebSocket/SSE updates
        v
Laravel Backend API
        |
        v
MySQL Database
        |
        +-- File storage
        +-- Queue workers
        +-- Scheduled jobs
        +-- Notification services
        +-- Backup storage

Flutter local storage:

- Drift with SQLite for structured offline data
- Flutter Secure Storage for authentication secrets
- Local file cache for pending attachments
- SharedPreferences only for harmless UI preferences

Do not use SharedPreferences as the main business-data database.

The production system must not rely only on a local SQLite database because multiple employees may use the system simultaneously.

The application must support:

- Server-side primary database
- Offline local database
- Synchronization queue
- Retry of failed synchronization
- Conflict detection
- Sync status indicators
- Last synchronization timestamps

==================================================
5. RECOMMENDED TECHNOLOGY STACK
==================================================

Flutter application:

- Flutter using the current stable release approved for the project
- Dart with strict null safety
- Riverpod for state management
- GoRouter for routing
- Dio for API communication
- Drift and SQLite for offline data
- Freezed and json_serializable for immutable models and serialization
- Flutter Secure Storage for access credentials
- Connectivity Plus for network-status awareness
- Intl for date, time, currency, and number formatting
- Image Picker for image capture and selection
- File Picker for documents
- PDF generation and printing packages for invoices and reports
- QR code scanner and generator for animal identification
- FL Chart or another maintained chart library for analytics

Backend:

- Laravel REST API
- MySQL database
- Redis for caching, queues, and rate limiting where available
- Laravel queues for reports, notifications, imports, and large exports
- Laravel scheduler for alerts and recurring processes
- Role and permission management
- Private file storage with secure download endpoints
- API documentation using OpenAPI
- Automated database backup strategy

Do not tightly couple Flutter screens directly to HTTP calls. Use repositories, services, and domain models.

==================================================
6. DEVELOPMENT PRINCIPLES
==================================================

Follow these rules:

1. Use clean, maintainable, modular code.
2. Separate presentation, application, domain, and data layers.
3. Do not put business calculations inside UI widgets.
4. Do not directly access SQLite from screen widgets.
5. Do not directly call APIs from buttons without using services or repositories.
6. Use reusable form controls, tables, dialogs, cards, and loading states.
7. Use strong typing.
8. Add validation on both Flutter and backend.
9. The server is the final authority for business rules.
10. Protect all financial and animal-history records.
11. Important records must be soft-deleted rather than permanently removed.
12. Maintain complete audit history.
13. Use database transactions for multi-step operations.
14. Prevent duplicate submissions.
15. Support idempotency for offline synchronization requests.
16. Use pagination for large lists.
17. Use filters and search on major modules.
18. Use timezone-aware date handling.
19. Store backend timestamps in UTC and display them in the farm’s configured timezone.
20. Store financial values using decimal database fields, not floating-point fields.
21. Store milk and weight quantities with suitable decimal precision.
22. Do not silently ignore synchronization or validation failures.
23. Do not expose internal errors or stack traces to end users.

==================================================
7. ORGANIZATION AND MULTI-FARM STRUCTURE
==================================================

The system must support one organization managing one or more farms.

Hierarchy:

Organization
├── Farm 1
│   ├── Shed A
│   ├── Shed B
│   └── Store
├── Farm 2
│   ├── Shed A
│   └── Store
└── Central Office

Create support for:

- Organization
- Farm
- Branch
- Shed
- Pen or animal group
- Warehouse
- Milk collection point
- Storage tank
- Cost centre

Every relevant record must belong to an organization.

Records such as animals, milk production, employees, expenses, inventory, and sales must also be connected to the appropriate farm or branch.

Prevent users from accessing records outside their organization.

==================================================
8. AUTHENTICATION AND USER MANAGEMENT
==================================================

Implement:

- Secure login
- Logout
- Forgot-password workflow
- Password reset
- Change password
- Session management
- Device/session listing
- Session revocation
- Optional two-factor authentication
- Rate limiting
- Failed-login tracking
- Account lock or delay rules
- User activation and deactivation
- Profile management
- Farm-level access restrictions
- Role-based permissions

Possible roles:

1. Super Administrator
2. Organization Owner
3. Farm Manager
4. Assistant Manager
5. Veterinarian
6. Breeding Technician
7. Accountant
8. Storekeeper
9. Milking Supervisor
10. Farm Worker
11. Delivery Driver
12. Sales Officer
13. Viewer or Auditor

Permissions must be granular.

Examples:

- animals.view
- animals.create
- animals.update
- animals.sell
- animals.transfer
- animals.record_death
- milk.create
- milk.correct
- breeding.manage
- health.manage
- inventory.issue
- inventory.adjust
- sales.create
- payments.receive
- expenses.approve
- payroll.process
- reports.export
- users.manage
- audit_logs.view

A worker must not automatically receive access to financial reports.

A veterinarian must not automatically receive permission to change customer balances.

==================================================
9. FARM SETUP MODULE
==================================================

Create screens and APIs for:

- Organization profile
- Farm profile
- Farm address
- Farm contact information
- Farm logo
- Farm timezone
- Farm currency
- Measurement units
- Financial year
- Milk measurement preferences
- Weight measurement preferences
- Number formatting
- Tax configuration
- Invoice numbering
- Receipt numbering
- Animal ID numbering
- Shed management
- Pen or animal group management
- Warehouse management
- Milk tank management
- Cost-centre management

Farm settings should include:

- Default milk unit
- Default feed unit
- Default animal type
- Default sale rate
- Calving-reminder days
- Vaccination-reminder days
- Low-stock thresholds
- Medicine-expiry warning days
- Milk-withdrawal enforcement
- Negative-stock policy
- Approval thresholds
- Data-retention settings

==================================================
10. ANIMAL MANAGEMENT MODULE
==================================================

Every animal must have a permanent profile and history.

Animal profile fields:

Identity:

- Internal UUID
- Animal number
- Ear-tag number
- RFID number
- QR code
- Animal name
- Registration number
- External registry number
- Photograph

Classification:

- Species
- Cow
- Buffalo
- Bull
- Calf
- Heifer
- Other supported livestock
- Breed
- Gender
- Date of birth
- Estimated date of birth flag
- Age
- Colour
- Identifying marks
- Horn status

Location:

- Organization
- Farm
- Shed
- Pen
- Animal group

Origin:

- Born on farm
- Purchased
- Received as transfer
- Previous owner
- Supplier
- Purchase date
- Purchase price
- Transportation cost
- Veterinary inspection cost

Family:

- Mother animal
- Father animal
- Sire or semen reference
- Birth event
- Siblings where available

Measurements:

- Birth weight
- Current weight
- Body-condition score
- Height where required
- Weight history

Production status:

- Lactating
- Dry
- Pregnant
- Open
- Inseminated
- Calved
- Non-productive

Health status:

- Healthy
- Sick
- Under treatment
- Quarantined
- Milk restricted
- Disabled

Lifecycle status:

- Active
- Sold
- Transferred
- Deceased
- Missing
- Culled

Additional information:

- Insurance details
- Insurance policy number
- Insurance expiry
- Notes
- Attachments
- Created by
- Updated by
- Created timestamp
- Updated timestamp

Animal profile tabs:

1. Overview
2. Milk production
3. Breeding history
4. Pregnancy history
5. Calving history
6. Health history
7. Vaccinations
8. Deworming
9. Weight history
10. Feed consumption
11. Movements
12. Financial history
13. Documents
14. Audit history

Animal functions:

- Add animal
- Edit allowed fields
- Transfer animal between sheds
- Transfer animal between farms
- Assign animal group
- Print QR label
- Scan animal QR code
- Record weight
- Record body-condition score
- Mark animal sold
- Mark animal deceased
- Mark animal missing
- Restore mistakenly archived animal
- View complete timeline

Do not delete the history of sold, transferred, or deceased animals.

==================================================
11. ANIMAL MOVEMENT MODULE
==================================================

Record every important movement:

- Old farm
- New farm
- Old shed
- New shed
- Old group
- New group
- Movement date and time
- Movement reason
- Transport details
- Responsible employee
- Approval status
- Notes

Animal location must reflect the latest approved movement.

Movement history must remain immutable except through an authorized correction workflow.

==================================================
12. MILK PRODUCTION MODULE
==================================================

Milk must be recordable per animal and per milking session.

Milking sessions:

- Morning
- Afternoon
- Evening
- Custom session

Milk-entry fields:

- Date
- Session
- Farm
- Shed
- Animal
- Quantity
- Unit
- Milking start time
- Milking end time
- Employee
- Supervisor
- Milking machine
- Fat percentage
- SNF percentage
- Protein percentage
- Density
- Temperature
- Quality grade
- Conductivity where available
- Rejected quantity
- Rejection reason
- Notes
- Entry source
- Manual entry
- Imported
- Device integration
- Offline entry
- Created by
- Approval status

Support:

- Individual animal entry
- Quick-entry grid
- Bulk entry
- Group entry
- Import from CSV or Excel
- Future milk-machine integration
- Correction request
- Supervisor approval
- Duplicate-entry prevention

Automatic calculations:

- Daily production by animal
- Session production
- Shed production
- Farm production
- Average milk per lactating animal
- Seven-day average
- Thirty-day average
- Production increase or decrease
- Highest-producing animals
- Lowest-producing animals
- Abnormal production drop
- Rejected milk
- Sellable milk
- Milk under withdrawal
- Milk used internally
- Milk wastage

Production-drop alerts must use configurable thresholds.

Example:

If an animal’s production falls more than the configured percentage compared with its recent average, generate an alert for the farm manager.

==================================================
13. MILK COLLECTION, STORAGE, AND BALANCE
==================================================

Create milk collection batches.

Fields:

- Batch number
- Collection date and time
- Farm
- Shed
- Source sessions
- Total produced
- Total accepted
- Total rejected
- Milk restricted by medicine withdrawal
- Tank
- Tank opening quantity
- Quantity added
- Quantity removed
- Closing quantity
- Temperature
- Quality test
- Responsible employee

Track milk tanks:

- Tank number
- Tank name
- Capacity
- Location
- Current quantity
- Minimum temperature
- Maximum temperature
- Cleaning schedule
- Last cleaning date
- Maintenance status

Enforce the milk balance equation:

Opening Milk
+ Accepted Production
+ Transfers In
- Sales
- Internal Use
- Rejected Milk
- Spoilage
- Samples
- Transfers Out
= Closing Milk

Any unexplained difference must be recorded as a variance with:

- Difference quantity
- Reason
- Supporting note
- Responsible user
- Approval

==================================================
14. MILK QUALITY MODULE
==================================================

Support milk quality tests:

- Sample number
- Collection batch
- Customer delivery
- Test date and time
- Fat
- SNF
- Protein
- Lactose
- Density
- Temperature
- Acidity
- Added water test
- Antibiotic-residue test
- Bacterial result
- Somatic cell count where applicable
- Quality grade
- Pass or fail
- Tested by
- Laboratory
- Attachment
- Notes

Quality results may affect:

- Sellable status
- Customer pricing
- Rejection
- Farmer performance reports

==================================================
15. BREEDING MODULE
==================================================

Heat-detection record:

- Animal
- Detection date and time
- Symptoms
- Detection method
- Detected by
- Intensity
- Recommended action
- Notes

Breeding or insemination record:

- Animal
- Breeding date and time
- Natural or artificial
- Bull
- Semen batch
- Semen straw number
- Breed
- Supplier
- Technician
- Service number
- Insemination cost
- Heat record
- Notes

Pregnancy-check record:

- Animal
- Check date
- Method
- Veterinarian
- Result
- Pregnant
- Not pregnant
- Uncertain
- Estimated pregnancy age
- Expected calving date
- Follow-up date
- Notes

Breeding rules:

- Prevent invalid breeding records for male animals.
- Warn if the animal is below a configured breeding age.
- Warn if insemination is recorded too soon after calving.
- Calculate expected pregnancy-check dates.
- Calculate expected calving dates.
- Detect repeat breeding.
- Maintain complete service history.
- Do not overwrite previous failed insemination records.

==================================================
16. CALVING MODULE
==================================================

Calving record fields:

- Mother
- Expected calving date
- Actual calving date and time
- Calving type
- Normal
- Assisted
- Difficult
- Caesarean
- Number of calves
- Calf gender
- Calf condition
- Birth weight
- Veterinarian
- Complications
- Placenta status
- Mother condition
- Treatment required
- Notes
- Attachments

When calving is recorded:

1. Create one or more calf records.
2. Connect calves to their mother.
3. Update pregnancy status.
4. Create lactation information where applicable.
5. Create post-calving check reminders.
6. Record complications.
7. Preserve the entire birth event.

==================================================
17. CALF MANAGEMENT MODULE
==================================================

Calf fields:

- Calf animal number
- Ear tag
- QR code
- Mother
- Father or semen source
- Date and time of birth
- Gender
- Breed
- Birth weight
- Birth condition
- Colostrum given
- Colostrum date and time
- Colostrum quantity
- Navel treatment
- Weaning target date
- Actual weaning date
- Feed plan
- Growth target
- Current weight
- Vaccination schedule
- Health status
- Sale or transfer status

Calf reports:

- New births
- Calf mortality
- Weight gain
- Colostrum compliance
- Weaning due
- Vaccinations due
- Growth below target

==================================================
18. ANIMAL HEALTH MODULE
==================================================

Create a complete health timeline.

Health case fields:

- Case number
- Animal
- Reported date
- Symptoms
- Suspected disease
- Diagnosis
- Severity
- Temperature
- Body-condition score
- Isolation required
- Quarantine location
- Veterinarian
- Treatment plan
- Case status
- Open
- Monitoring
- Recovered
- Chronic
- Closed
- Follow-up date
- Notes
- Attachments

Treatment fields:

- Health case
- Animal
- Treatment date
- Medicine
- Dosage
- Unit
- Route
- Frequency
- Duration
- Start date
- End date
- Administered by
- Veterinarian
- Cost
- Response
- Adverse reaction
- Notes

The system must maintain:

- Complete medical history
- Diagnosis history
- Medicine usage
- Treatment cost
- Veterinarian history
- Laboratory attachments
- Follow-up reminders

==================================================
19. MEDICINE WITHDRAWAL RULES
==================================================

Medicine records must support:

- Milk withdrawal period
- Meat withdrawal period

When a treatment uses a medicine with a milk-withdrawal period:

1. Automatically create a milk restriction.
2. Store restriction start date and end date.
3. Display a warning on the animal profile.
4. Mark the animal clearly during milk entry.
5. Exclude restricted milk from sellable stock.
6. Record restricted milk separately.
7. Generate an alert when the restriction is about to end.
8. Allow an authorized veterinarian or manager to extend the restriction.
9. Require a reason and audit log for manual overrides.

Do not allow restricted milk to be sold without an explicit authorized override.

==================================================
20. VACCINATION AND DEWORMING MODULE
==================================================

Vaccination fields:

- Animal or animal group
- Vaccine
- Disease covered
- Dose
- Unit
- Vaccination date
- Next due date
- Batch number
- Expiry date
- Supplier
- Veterinarian
- Administered by
- Cost
- Reaction
- Notes
- Certificate attachment

Deworming fields:

- Animal or group
- Product
- Dose
- Date
- Next due date
- Employee
- Cost
- Notes

Support:

- Individual scheduling
- Group scheduling
- Farm-wide campaigns
- Recurring schedules
- Upcoming reminders
- Overdue alerts
- Completion recording
- Missed-dose reporting

==================================================
21. FEED ITEM MODULE
==================================================

Feed categories:

- Green fodder
- Dry fodder
- Silage
- Concentrate
- Minerals
- Supplements
- Calf starter
- Farm-produced feed
- Purchased feed
- Other

Feed item fields:

- Item code
- Feed name
- Category
- Brand
- Unit
- Current cost
- Average cost
- Minimum stock
- Maximum stock
- Reorder quantity
- Warehouse
- Supplier
- Batch tracking
- Expiry tracking
- Nutritional values
- Dry matter
- Protein
- Energy
- Fibre
- Fat
- Minerals
- Notes

==================================================
22. FEED RATION AND CONSUMPTION MODULE
==================================================

Create ration plans for:

- Lactating animals
- High-producing animals
- Pregnant animals
- Dry animals
- Calves
- Heifers
- Bulls
- Sick animals
- Custom animal groups

Ration plan fields:

- Plan name
- Farm
- Animal type or group
- Production stage
- Effective date
- End date
- Feed ingredients
- Quantity per animal
- Unit
- Feeding frequency
- Estimated cost
- Nutritional totals
- Created by
- Approved by

Daily feed issue:

- Date
- Shed
- Animal group
- Feed item
- Planned quantity
- Issued quantity
- Consumed quantity
- Wasted quantity
- Returned quantity
- Employee
- Notes

Automatic calculations:

- Feed cost per animal
- Feed cost per group
- Feed cost per litre of milk
- Feed conversion indicators
- Feed wastage
- Stock consumption
- Number of stock days remaining
- Planned versus actual feed usage

==================================================
23. INVENTORY MANAGEMENT MODULE
==================================================

Inventory categories:

- Feed
- Medicines
- Vaccines
- Semen
- Cleaning supplies
- Milking supplies
- Packaging
- Fuel
- Spare parts
- Tools
- Safety items
- General supplies

Inventory item fields:

- Item code
- Barcode
- Name
- Category
- Brand
- Unit
- Purchase unit
- Issue unit
- Conversion rate
- Warehouse
- Minimum stock
- Maximum stock
- Reorder point
- Batch controlled
- Expiry controlled
- Serial controlled
- Current stock
- Average cost
- Last purchase cost
- Active status

Stock movements:

- Opening stock
- Purchase receipt
- Issue
- Return
- Transfer
- Adjustment
- Damage
- Expiry
- Consumption
- Sale

Every stock movement must record:

- Date and time
- Item
- Batch
- Quantity
- Unit
- Source location
- Destination location
- Cost
- Reference type
- Reference number
- User
- Reason
- Approval status

Do not directly update an item’s stock number without creating a stock movement.

Negative stock must be blocked by default.

Stock adjustments must require permission and an audit log.

==================================================
24. SUPPLIER AND PURCHASING MODULE
==================================================

Supplier fields:

- Supplier code
- Supplier name
- Contact person
- Phone
- Email
- Address
- Tax information
- Supplier categories
- Payment terms
- Credit limit
- Opening balance
- Active status
- Documents
- Notes

Purchasing workflow:

1. Purchase request
2. Approval
3. Request for quotation where required
4. Purchase order
5. Goods receipt
6. Quality inspection
7. Supplier invoice
8. Payment
9. Purchase return

Purchase fields:

- Purchase number
- Supplier
- Farm
- Warehouse
- Purchase date
- Invoice number
- Items
- Batch
- Expiry
- Quantity
- Rate
- Discount
- Tax
- Transport cost
- Other cost
- Total
- Paid
- Balance
- Payment status
- Approval status
- Attachments

Receiving inventory must automatically create stock movements.

==================================================
25. CUSTOMER MANAGEMENT MODULE
==================================================

Customer fields:

- Customer code
- Customer name
- Customer type
- Individual
- Shop
- Distributor
- Milk collection company
- Factory
- Institution
- Phone
- Email
- Address
- Delivery address
- Tax information
- Credit limit
- Payment terms
- Default milk rate
- Quality-based pricing
- Opening balance
- Current balance
- Route
- Active status
- Notes

Customer functions:

- Customer statement
- Sales history
- Payment history
- Outstanding amount
- Credit-limit warning
- Customer-specific pricing
- Delivery schedule
- Printable ledger

==================================================
26. MILK SALES MODULE
==================================================

Milk sale fields:

- Invoice number
- Date and time
- Customer
- Farm
- Milk batch
- Quantity
- Unit
- Base rate
- Fat-based adjustment
- SNF-based adjustment
- Quality adjustment
- Discount
- Tax
- Delivery charges
- Total amount
- Paid amount
- Balance
- Payment method
- Delivery status
- Salesperson
- Driver
- Vehicle
- Notes

Sales statuses:

- Draft
- Confirmed
- Dispatched
- Delivered
- Partially delivered
- Cancelled
- Returned

Rules:

- A confirmed sale must reduce available milk stock.
- A cancelled sale must reverse stock through a controlled transaction.
- A return must create a return record.
- Do not permit sale quantities greater than available sellable milk unless an authorized policy permits it.
- Do not include medicine-restricted milk in available sellable stock.
- Customer balances must update automatically.
- Payments must create ledger entries.
- Corrections must remain auditable.

Generate:

- Invoice
- Receipt
- Delivery note
- Customer statement
- Daily sales summary
- Outstanding report

==================================================
27. DELIVERY MANAGEMENT MODULE
==================================================

Create:

- Delivery routes
- Route stops
- Vehicles
- Drivers
- Delivery schedules
- Delivery manifests

Delivery record fields:

- Delivery number
- Date
- Route
- Vehicle
- Driver
- Customers
- Planned quantities
- Loaded quantity
- Delivered quantity
- Returned quantity
- Rejected quantity
- Payment collected
- Delivery time
- Customer signature
- Proof-of-delivery image
- GPS coordinates where permission is granted
- Notes

Statuses:

- Scheduled
- Loading
- Dispatched
- On route
- Delivered
- Partially delivered
- Failed
- Returned

==================================================
28. ANIMAL PURCHASE AND SALE MODULE
==================================================

Animal purchase record:

- Animal
- Seller
- Purchase date
- Purchase price
- Transport cost
- Veterinary cost
- Commission
- Total acquisition cost
- Payment status
- Previous production
- Pregnancy status at purchase
- Health inspection
- Documents

Animal sale record:

- Animal
- Buyer
- Sale date
- Sale price
- Weight
- Sale reason
- Transport cost
- Payment status
- Profit or loss
- Documents

A sold animal must remain searchable in historical reports.

==================================================
29. ANIMAL MORTALITY AND DISPOSAL MODULE
==================================================

Record:

- Animal
- Date and time of death
- Place
- Suspected cause
- Confirmed cause
- Last illness
- Veterinarian
- Post-mortem report
- Disposal method
- Disposal date
- Disposal cost
- Insurance claim
- Compensation
- Attachments
- Notes

Do not permanently delete mortality records.

==================================================
30. FINANCE AND ACCOUNTING MODULE
==================================================

At minimum, manage:

- Cash accounts
- Bank accounts
- Mobile wallet accounts
- Income
- Expenses
- Customer receivables
- Supplier payables
- Employee advances
- Payments received
- Payments made
- Transfers between accounts
- Opening balances
- Closing balances
- Daily cash book

Income categories:

- Milk sales
- Animal sales
- Manure sales
- Feed sales
- Government support
- Insurance compensation
- Other income

Expense categories:

- Feed
- Medicine
- Vaccination
- Veterinary charges
- Salaries
- Electricity
- Fuel
- Transport
- Repairs
- Rent
- Water
- Equipment
- Animal purchase
- Insurance
- Taxes
- Cleaning
- Laboratory
- Miscellaneous

Expense fields:

- Expense number
- Date
- Category
- Farm
- Cost centre
- Supplier or payee
- Amount
- Tax
- Payment account
- Payment method
- Reference
- Description
- Receipt
- Requested by
- Approved by
- Approval status

Use a proper transaction and ledger approach.

Do not calculate balances only from editable fields.

Financial reports:

- Daily cash book
- Income report
- Expense report
- Profit and loss
- Cash flow
- Customer receivables
- Supplier payables
- Account ledger
- Cost by farm
- Cost by shed
- Cost per animal
- Cost per litre of milk
- Animal profitability
- Farm profitability

==================================================
31. EMPLOYEE MANAGEMENT MODULE
==================================================

Employee fields:

- Employee number
- Name
- Photograph
- Phone
- Email
- Identification number
- Address
- Emergency contact
- Designation
- Department
- Farm
- Shed
- Joining date
- Employment type
- Salary type
- Basic salary
- Shift
- Bank details
- Documents
- Active status

Employee functions:

- Assignment to farm
- Assignment to shed
- Role and permissions
- Attendance
- Leave
- Overtime
- Advances
- Deductions
- Bonuses
- Payroll
- Tasks
- Performance notes

Sensitive employee information must be access-controlled.

==================================================
32. ATTENDANCE AND PAYROLL MODULE
==================================================

Attendance:

- Date
- Employee
- Shift
- Check-in
- Check-out
- Hours worked
- Late minutes
- Overtime
- Status
- Present
- Absent
- Leave
- Holiday
- Notes

Payroll:

- Payroll period
- Employee
- Basic salary
- Attendance adjustment
- Overtime
- Bonus
- Allowances
- Deductions
- Advance recovery
- Net salary
- Payment date
- Payment account
- Status
- Payslip

Payroll must be approved before payment.

==================================================
33. TASK AND WORK-ORDER MODULE
==================================================

Tasks may include:

- Clean shed
- Vaccinate animals
- Inspect sick animal
- Repair milking machine
- Deliver milk
- Purchase feed
- Transfer animals
- Check pregnancy
- Clean milk tank

Task fields:

- Task number
- Title
- Description
- Farm
- Shed
- Animal
- Equipment
- Assigned user
- Priority
- Start date
- Due date
- Recurrence
- Status
- Checklist
- Completion notes
- Before photo
- After photo
- Approved by

Statuses:

- New
- Assigned
- In progress
- Blocked
- Completed
- Verified
- Cancelled

==================================================
34. EQUIPMENT AND MAINTENANCE MODULE
==================================================

Equipment examples:

- Milking machines
- Chillers
- Milk tanks
- Generators
- Pumps
- Tractors
- Feed mixers
- Scales
- Vehicles
- Refrigerators
- Ventilation systems

Asset fields:

- Asset number
- Name
- Category
- Brand
- Model
- Serial number
- Purchase date
- Purchase price
- Supplier
- Warranty
- Farm
- Location
- Assigned employee
- Status
- Meter reading
- Service interval
- Next service date
- Documents

Maintenance fields:

- Work-order number
- Asset
- Issue
- Reported date
- Priority
- Assigned technician
- Service provider
- Parts used
- Labour cost
- Total cost
- Downtime
- Completion date
- Next service
- Notes

Parts used must create inventory issues.

==================================================
35. NOTIFICATIONS AND ALERTS
==================================================

Support in-app alerts first.

Prepare the architecture for:

- Push notifications
- Email
- SMS
- WhatsApp integration

Alert types:

- Vaccination due
- Deworming due
- Pregnancy check due
- Expected calving
- Repeat insemination
- Treatment follow-up
- Milk-withdrawal period
- Low feed stock
- Low medicine stock
- Feed expiry
- Medicine expiry
- Vaccine expiry
- Semen expiry
- Customer payment overdue
- Supplier payment due
- Task overdue
- Equipment maintenance due
- Milk production drop
- Tank temperature warning
- Unexplained milk variance
- Animal-health warning
- Backup failure
- Synchronization failure

Every alert should contain:

- Type
- Severity
- Title
- Description
- Related record
- Farm
- Due date
- Status
- Read timestamp
- Resolved timestamp
- Assigned user

Avoid creating the same active alert repeatedly.

==================================================
36. DASHBOARD
==================================================

Create role-specific dashboards.

Owner dashboard:

- Total animals
- Active animals
- Lactating animals
- Pregnant animals
- Dry animals
- Sick animals
- Animals under treatment
- Calves
- Animals due for vaccination
- Expected calvings
- Today’s milk production
- Yesterday’s production
- Seven-day average
- Average milk per animal
- Sellable milk
- Restricted milk
- Milk sold
- Milk remaining
- Today’s income
- Today’s expenses
- Current cash
- Customer outstanding
- Supplier payable
- Feed stock days remaining
- Important alerts

Manager dashboard:

- Animal status
- Milk performance
- Production drops
- Health cases
- Breeding tasks
- Staff attendance
- Open tasks
- Inventory warnings

Veterinarian dashboard:

- Sick animals
- Open cases
- Treatments due
- Follow-ups
- Vaccinations due
- Withdrawal periods
- Expected calvings

Storekeeper dashboard:

- Low stock
- Expiring items
- Pending receipts
- Pending issues
- Stock adjustments
- Purchase orders

Do not display placeholder numbers.

==================================================
37. REPORTS
==================================================

All major reports must support:

- Date filters
- Farm filters
- Shed filters
- Animal filters
- Status filters
- Search
- Sorting
- Pagination
- PDF export
- Excel or CSV export
- Printing where applicable

Animal reports:

- Complete animal list
- Animal profile
- Animal timeline
- Breed-wise report
- Farm-wise report
- Shed-wise report
- Animal status report
- Purchases
- Sales
- Transfers
- Mortality
- Weight history

Milk reports:

- Daily production
- Session production
- Animal-wise production
- Shed-wise production
- Farm-wise production
- Monthly comparison
- Production trend
- Rejected milk
- Restricted milk
- Milk balance
- Milk variance
- Quality report

Breeding reports:

- Heat detections
- Inseminations
- Repeat breeders
- Pregnancy checks
- Pregnant animals
- Expected calvings
- Calving history
- Abortion or pregnancy-loss report
- Breeding success rate

Health reports:

- Sick animals
- Open health cases
- Treatment history
- Medicine usage
- Vaccinations due
- Vaccination history
- Deworming history
- Withdrawal periods
- Veterinarian performance
- Health cost per animal

Feed and inventory reports:

- Current stock
- Stock ledger
- Low stock
- Expiring stock
- Feed consumption
- Feed wastage
- Feed cost
- Feed cost per litre
- Purchase history
- Stock adjustments

Sales and customer reports:

- Daily sales
- Customer-wise sales
- Product or quality-wise sales
- Customer statements
- Outstanding balances
- Payment collections
- Delivery performance
- Returns

Finance reports:

- Income
- Expenses
- Profit and loss
- Cash flow
- Cash book
- Account ledger
- Receivables
- Payables
- Farm profitability
- Animal profitability
- Cost per litre

Employee reports:

- Attendance
- Overtime
- Leave
- Payroll
- Advances
- Task completion
- Farm-wise workforce

==================================================
38. SEARCH AND FILTERING
==================================================

Implement global and module-specific search.

Users should be able to search animals using:

- Animal number
- Ear tag
- RFID
- QR code
- Name
- Breed
- Mother
- Farm
- Shed
- Status

Other modules must support suitable search and filters.

Use server-side pagination for large records.

Preserve selected filters while navigating back from detail pages where practical.

==================================================
39. DOCUMENTS AND ATTACHMENTS
==================================================

Support upload of:

- Animal photos
- Veterinary prescriptions
- Laboratory results
- Vaccination certificates
- Purchase invoices
- Expense receipts
- Customer documents
- Supplier documents
- Employee documents
- Insurance policies
- Animal purchase agreements
- Animal sale agreements
- Proof-of-delivery images
- Equipment manuals

Attachment fields:

- Original filename
- Stored filename
- MIME type
- File size
- Checksum
- Storage path
- Related entity
- Uploaded by
- Upload date
- Description

Security:

- Validate file type
- Validate file size
- Generate safe filenames
- Store private files outside public directories
- Use authorized download endpoints
- Prevent executable uploads
- Log access to sensitive files where required

==================================================
40. OFFLINE-FIRST REQUIREMENTS
==================================================

Farm employees may have unstable internet.

The application must allow selected operations offline:

- View recently synchronized animals
- Search locally cached animals
- Scan animal QR code
- Record milk production
- Record animal weight
- Record health observation
- Record vaccination
- Complete assigned tasks
- Capture photographs
- Record feed issue
- Record expense draft
- Record delivery status

Offline record requirements:

- Local UUID
- Server UUID when synchronized
- Device ID
- User ID
- Created-at timestamp
- Updated-at timestamp
- Sync status
- Retry count
- Last error
- Idempotency key

Sync states:

- Local only
- Pending
- Uploading
- Synced
- Failed
- Conflict

Synchronization rules:

1. Do not lose local data after an API failure.
2. Retry failed requests with controlled backoff.
3. Show pending-sync count.
4. Allow the user to inspect failed records.
5. Prevent duplicate server records.
6. Synchronize reference data before dependent transactions.
7. Upload attachments after their parent record exists.
8. Keep audit information for offline-created records.
9. Never claim a record is synchronized before server confirmation.
10. Provide a manual “Sync now” action.

Conflict handling:

- Use UUIDs.
- Use updated-at/version fields.
- Detect conflicting edits.
- Do not silently overwrite financial, milk, health, breeding, or inventory records.
- Show conflicts to an authorized user.
- Allow controlled resolution.
- Preserve original versions in audit history.

==================================================
41. DATABASE DESIGN REQUIREMENTS
==================================================

Use:

- UUID primary identifiers for records that synchronize offline
- Foreign keys
- Appropriate indexes
- Unique constraints
- Decimal fields for money and quantities
- Soft deletes
- Created-by and updated-by fields where important
- Organization ID on tenant-owned records
- Farm ID where applicable
- Optimistic version field for conflict detection

Suggested core tables include:

- organizations
- farms
- branches
- sheds
- pens
- warehouses
- milk_tanks
- users
- roles
- permissions
- user_farm_access
- employees
- animals
- animal_breeds
- animal_groups
- animal_movements
- animal_weights
- body_condition_scores
- animal_purchases
- animal_sales
- animal_mortalities
- milk_sessions
- milk_entries
- milk_collection_batches
- milk_batch_sources
- milk_tank_movements
- milk_quality_tests
- milk_restrictions
- heat_records
- breeding_services
- pregnancy_checks
- pregnancies
- calving_events
- calves
- health_cases
- treatments
- treatment_medicines
- medicines
- vaccines
- vaccination_schedules
- vaccinations
- deworming_records
- feed_items
- ration_plans
- ration_plan_items
- feed_issues
- inventory_items
- inventory_batches
- stock_movements
- suppliers
- purchase_requests
- purchase_orders
- purchase_receipts
- purchase_invoices
- purchase_returns
- customers
- milk_sales
- sale_items
- customer_payments
- delivery_routes
- deliveries
- delivery_items
- accounts
- financial_transactions
- expenses
- income_records
- account_transfers
- employee_attendance
- leave_requests
- payroll_periods
- payroll_entries
- employee_advances
- tasks
- task_checklists
- assets
- maintenance_work_orders
- alerts
- notifications
- attachments
- comments
- approvals
- audit_logs
- sync_devices
- sync_operations
- settings

Do not create one huge generic table for unrelated modules.

Use clear relationships and domain-specific records.

==================================================
42. IMPORTANT BUSINESS RULES
==================================================

Implement and test these rules:

1. A sold or deceased animal cannot receive normal milk records.
2. A male animal cannot have a pregnancy record.
3. Restricted milk cannot be sold through the normal sale flow.
4. Inventory cannot become negative unless an explicit organization policy allows it.
5. Stock quantity changes must come from stock movements.
6. Customer balance changes must come from sales, returns, receipts, or adjustments.
7. Supplier balance changes must come from purchases, returns, payments, or adjustments.
8. Financial transactions must not be physically deleted after posting.
9. Milk sales must reduce sellable milk stock.
10. Sale cancellation must reverse related stock and ledger effects.
11. Animal transfer must update the animal’s location only after approval where approval is enabled.
12. Calving must close or update the related pregnancy.
13. Calving should create calf records.
14. Medicine withdrawal must create milk restrictions.
15. Duplicate milk entry for the same animal, date, and session must be prevented unless authorized correction is used.
16. Expired medicines and vaccines must generate warnings and must not be issued without authorized override.
17. Completed vaccination must update the next due schedule.
18. Purchase receipts must increase inventory.
19. Inventory issue must reduce inventory.
20. Payroll payment must create a financial transaction.
21. Posted financial periods must be protected from ordinary edits.
22. Every override must include a reason.
23. Every important change must be auditable.

==================================================
43. AUDIT LOGS
==================================================

Audit:

- Login
- Failed login
- Logout
- Password change
- Record creation
- Record update
- Record deletion
- Record restoration
- Approval
- Rejection
- Financial posting
- Stock adjustment
- Milk correction
- Treatment override
- Withdrawal override
- User-permission change
- Export of sensitive reports
- Backup and restore

Audit log fields:

- Organization
- User
- Action
- Entity type
- Entity ID
- Old values
- New values
- Reason
- IP address
- Device
- Request ID
- Timestamp

Audit logs must not be editable through ordinary application functionality.

==================================================
44. APPROVAL WORKFLOWS
==================================================

Prepare reusable approval workflows for:

- Large expenses
- Stock adjustments
- Animal sale
- Animal transfer
- Milk correction
- Financial adjustment
- Purchase order
- Purchase invoice
- Payroll
- Restricted-milk override
- Record reopening

Approval fields:

- Requester
- Approver
- Status
- Requested date
- Approval date
- Reason
- Rejection reason
- Comments

==================================================
45. API REQUIREMENTS
==================================================

Create versioned APIs.

Example base path:

/api/v1

API groups:

- auth
- profile
- organizations
- farms
- sheds
- animals
- milk
- breeding
- health
- vaccinations
- feed
- inventory
- suppliers
- purchases
- customers
- sales
- deliveries
- finance
- employees
- attendance
- payroll
- tasks
- equipment
- alerts
- reports
- files
- sync
- settings
- audit

API standards:

- Consistent JSON response format
- Proper HTTP status codes
- Validation-error details
- Pagination metadata
- Filter and sorting support
- Request IDs
- Idempotency keys for important creates
- Rate limiting
- Authorization policies
- OpenAPI documentation
- Automated API tests

Do not expose database models directly without controlled API resources.

==================================================
46. FLUTTER PROJECT STRUCTURE
==================================================

Use a feature-first structure with shared core services.

Suggested structure:

lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── bootstrap.dart
├── core/
│   ├── api/
│   ├── auth/
│   ├── database/
│   ├── errors/
│   ├── logging/
│   ├── network/
│   ├── permissions/
│   ├── sync/
│   ├── storage/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── authentication/
│   ├── dashboard/
│   ├── farms/
│   ├── animals/
│   ├── milk/
│   ├── breeding/
│   ├── health/
│   ├── vaccinations/
│   ├── feed/
│   ├── inventory/
│   ├── purchasing/
│   ├── customers/
│   ├── sales/
│   ├── deliveries/
│   ├── finance/
│   ├── employees/
│   ├── attendance/
│   ├── payroll/
│   ├── tasks/
│   ├── equipment/
│   ├── alerts/
│   ├── reports/
│   ├── settings/
│   └── audit/
└── main.dart

Each feature should contain suitable folders such as:

- data
- domain
- application
- presentation

Avoid creating unnecessary abstractions, but maintain clear separation of concerns.

==================================================
47. USER INTERFACE REQUIREMENTS
==================================================

The design should be professional, simple, and usable by non-technical farm workers.

Design priorities:

- Large touch targets
- Clear labels
- Readable typography
- High contrast
- Quick animal lookup
- Quick milk entry
- Minimal typing for common tasks
- Confirmation before destructive actions
- Loading indicators
- Empty states
- Error states
- Retry actions
- Offline indicators
- Sync indicators
- Permission-aware navigation

Use:

- Bottom navigation for common mobile actions
- Navigation rail or sidebar on tablets and web
- Searchable dropdowns
- Date pickers
- Number input controls
- Unit display
- QR scanning
- Photo capture
- Paginated tables on large screens
- Cards and compact lists on mobile

Do not build only desktop tables that are unusable on phones.

==================================================
48. RECOMMENDED MAIN NAVIGATION
==================================================

Dashboard

Farm
- Farms
- Sheds
- Pens
- Warehouses
- Milk Tanks

Animals
- All Animals
- Add Animal
- Groups
- Movements
- Weights
- Purchases
- Sales
- Mortality

Milk
- Quick Entry
- Production
- Collection Batches
- Storage
- Quality Tests
- Restricted Milk
- Milk Balance

Breeding
- Heat Records
- Inseminations
- Pregnancy Checks
- Pregnant Animals
- Expected Calving
- Calving Records
- Calves

Health
- Health Cases
- Treatments
- Medicines
- Vaccinations
- Deworming
- Follow-ups
- Withdrawal Periods

Feed
- Feed Items
- Ration Plans
- Daily Feed
- Feed Consumption
- Feed Stock

Inventory
- Items
- Stock
- Stock Movements
- Transfers
- Adjustments
- Low Stock
- Expiry Alerts

Purchasing
- Suppliers
- Purchase Requests
- Purchase Orders
- Goods Receipts
- Invoices
- Returns
- Payments

Sales
- Customers
- Milk Sales
- Deliveries
- Invoices
- Receipts
- Outstanding Balances

Finance
- Dashboard
- Income
- Expenses
- Accounts
- Receivables
- Payables
- Cash Book
- Profit and Loss

Employees
- Employees
- Attendance
- Leave
- Payroll
- Advances
- Tasks

Equipment
- Assets
- Maintenance
- Repairs

Reports
Alerts
Audit Logs
Users and Permissions
Settings
Backup and Restore

Hide menu items when the user lacks permission.

==================================================
49. SECURITY REQUIREMENTS
==================================================

Implement:

- HTTPS-only production communication
- Secure token storage
- Token expiration
- Refresh or session renewal strategy
- Logout revocation
- Input validation
- Output encoding
- SQL injection protection
- CSRF strategy appropriate to the authentication method
- Brute-force protection
- Rate limiting
- Permission checks
- Tenant isolation
- Secure file uploads
- File-access authorization
- Sensitive-field encryption where appropriate
- Audit logs
- Backup encryption
- Secrets stored outside source code
- Environment-specific configuration
- Production error handling
- Dependency vulnerability review

Never hard-code:

- API secrets
- Database passwords
- Encryption keys
- Admin passwords
- Production URLs
- Signing secrets

==================================================
50. BACKUP, RESTORE, IMPORT, AND EXPORT
==================================================

Implement or prepare:

- Automated database backups
- Manual backup command
- Backup status
- Backup failure alerts
- Restore procedure documentation
- File-storage backup
- Backup retention settings
- Encrypted backup option
- Test restoration procedure

Data import:

- Animals
- Customers
- Suppliers
- Employees
- Opening inventory
- Opening balances
- Historical milk records

Import requirements:

- Downloadable templates
- Validation preview
- Error report
- Duplicate detection
- Transactional import
- Do not partially import invalid files unless explicitly using a controlled partial-import mode

Exports:

- CSV
- Excel where supported
- PDF reports
- Printable invoices
- Customer statements
- Animal history

==================================================
51. TESTING REQUIREMENTS
==================================================

Flutter tests:

- Unit tests
- Widget tests
- Repository tests
- API-client tests
- Database tests
- Sync tests
- Validation tests
- Permission tests
- Critical workflow integration tests

Backend tests:

- Authentication
- Authorization
- Tenant isolation
- Animal lifecycle
- Milk entry
- Duplicate prevention
- Milk withdrawal
- Milk stock balance
- Inventory movement
- Negative stock prevention
- Sales posting
- Customer balance
- Purchase receipt
- Supplier balance
- Financial transactions
- Offline idempotency
- Approval workflows
- Audit logs

Critical end-to-end scenarios:

1. Create farm and shed.
2. Add animal.
3. Record milk.
4. Create treatment with withdrawal.
5. Verify milk becomes restricted.
6. Attempt prohibited restricted-milk sale.
7. Record breeding.
8. Confirm pregnancy.
9. Record calving.
10. Verify calf creation.
11. Purchase feed.
12. Receive stock.
13. Issue feed.
14. Verify inventory balance.
15. Sell milk.
16. Receive customer payment.
17. Verify customer ledger.
18. Record expense.
19. Generate profit-and-loss report.
20. Create offline milk entry and synchronize it once without duplication.

==================================================
52. PERFORMANCE REQUIREMENTS
==================================================

The application must remain usable with:

- Thousands of animals
- Years of milk records
- Large stock ledgers
- Large customer ledgers
- Multiple farms
- Multiple concurrent users

Use:

- Server-side pagination
- Database indexes
- Efficient queries
- Background report generation
- Image compression
- Lazy loading
- Cached reference data
- Controlled local database size
- Incremental synchronization

Avoid downloading the complete production database to every device.

==================================================
53. ACCESSIBILITY AND LOCALIZATION
==================================================

Prepare for:

- English
- Urdu
- Other languages later

Do not hard-code user-facing text throughout widgets.

Use localization files.

Support:

- Left-to-right layouts
- Future right-to-left layout
- Configurable date formats
- Configurable currency
- Configurable units
- Accessible labels
- Sufficient contrast
- Scalable text

==================================================
54. DEVELOPMENT PHASES
==================================================

Do not build all modules simultaneously.

PHASE 0: Discovery and architecture

Deliver:

- Requirements review
- Assumptions
- Technical architecture
- Database ERD
- Module dependency map
- API conventions
- Flutter folder structure
- Backend folder structure
- Security model
- Offline-sync design
- Development plan
- Risk register

Do not start large-scale coding until this phase is reviewed.

PHASE 1: Foundation

Implement:

- Flutter project initialization
- Backend initialization
- Environment configuration
- Authentication
- User sessions
- Roles and permissions
- Organization
- Farm
- Shed
- Responsive application shell
- API client
- Error handling
- Local database
- Sync foundation
- Audit foundation
- Automated testing foundation

PHASE 2: Animal management

Implement:

- Animal profiles
- Breeds
- Groups
- Movements
- Weight records
- QR generation
- QR scanning
- Animal timeline
- Animal search
- Animal status management

PHASE 3: Milk management

Implement:

- Milking sessions
- Quick milk entry
- Milk production
- Collection batches
- Milk tanks
- Milk balance
- Milk quality
- Production reports
- Production-drop alerts

PHASE 4: Health and breeding

Implement:

- Health cases
- Treatments
- Medicines
- Withdrawal periods
- Vaccinations
- Deworming
- Heat detection
- Insemination
- Pregnancy checks
- Calving
- Calf creation
- Health and breeding alerts

PHASE 5: Feed and inventory

Implement:

- Feed items
- Ration plans
- Feed issue
- Inventory items
- Batches
- Stock movements
- Transfers
- Adjustments
- Low-stock alerts
- Expiry alerts

PHASE 6: Purchasing, customers, and sales

Implement:

- Suppliers
- Purchase orders
- Receiving
- Supplier invoices
- Customers
- Milk sales
- Customer payments
- Delivery
- Customer and supplier ledgers

PHASE 7: Finance and employees

Implement:

- Accounts
- Expenses
- Income
- Cash book
- Profit and loss
- Employees
- Attendance
- Payroll
- Advances
- Tasks

PHASE 8: Equipment, reports, and advanced offline sync

Implement:

- Assets
- Maintenance
- Advanced reports
- PDF and Excel exports
- Offline conflict resolution
- Background synchronization
- Backup monitoring

PHASE 9: Hardening and release

Perform:

- Security review
- Performance testing
- Data-integrity testing
- Accessibility review
- Localization review
- Backup restoration test
- Production configuration
- Release builds
- Deployment documentation
- User manual
- Administrator manual

==================================================
55. MVP SCOPE
==================================================

The first usable MVP must include:

1. Login
2. Roles and permissions
3. Organization and farm
4. Sheds
5. Animal profiles
6. Animal movement
7. Milk production
8. Basic milk balance
9. Health records
10. Treatments
11. Medicine withdrawal
12. Vaccination reminders
13. Breeding
14. Pregnancy
15. Calving
16. Calf records
17. Feed items
18. Basic inventory
19. Suppliers and purchases
20. Customers
21. Milk sales
22. Customer payments
23. Expenses
24. Dashboard
25. Basic reports
26. Audit logs
27. Offline milk entry
28. Backup documentation

Do not add AI prediction, IoT devices, RFID hardware integration, or advanced machine learning before the core workflows are complete and verified.

==================================================
56. FUTURE FEATURES
==================================================

Prepare extension points for:

- RFID readers
- Digital weighing scales
- Milk meters
- Tank-temperature sensors
- Animal activity trackers
- GPS livestock tracking
- Facial or image-based animal recognition
- Automatic heat detection
- Mastitis prediction
- Milk-yield prediction
- Feed optimization
- Disease-risk analysis
- WhatsApp alerts
- Customer ordering portal
- Farmer marketplace
- Veterinary teleconsultation
- Government registry integration

Do not implement these before approval.

==================================================
57. SEED AND DEMO DATA
==================================================

Create realistic development seed data:

- One organization
- Two farms
- Multiple sheds
- At least 30 animals
- Cows, buffaloes, bulls, heifers, and calves
- Multiple breeds
- Milk records for at least 30 days
- Pregnant animals
- Animals under treatment
- One active withdrawal restriction
- Vaccinations
- Feed items
- Medicines
- Inventory batches
- Suppliers
- Purchases
- Customers
- Milk sales
- Payments
- Employees
- Attendance
- Expenses
- Equipment
- Alerts

Do not use meaningless values such as Test 1, Test 2, or abc everywhere.

==================================================
58. DOCUMENTATION REQUIREMENTS
==================================================

Maintain:

- README
- Installation guide
- Environment-variable guide
- Architecture document
- ERD
- API documentation
- Flutter structure document
- Offline-sync document
- Permission matrix
- Business-rules document
- Testing guide
- Deployment guide
- Backup and restore guide
- User manual
- Changelog

For each completed phase, provide:

- What was implemented
- Files created
- Files changed
- Database migrations
- API endpoints
- Screens
- Tests
- Commands to run
- Known limitations
- Remaining work
- Screenshots where practical

==================================================
59. CODE QUALITY GATES
==================================================

Before declaring a phase complete:

Flutter:

- flutter analyze passes
- dart format check passes
- Unit tests pass
- Widget tests pass
- App builds successfully
- No hard-coded secrets
- No unresolved critical TODO comments
- No unhandled API errors in implemented workflows

Backend:

- Code formatter passes
- Static analysis passes
- Automated tests pass
- Migrations run on a clean database
- Seeders run successfully
- API documentation is updated
- Authorization tests pass
- Tenant-isolation tests pass

Database:

- Foreign keys exist
- Indexes exist
- Unique constraints exist
- Decimal precision is appropriate
- Soft deletion is configured where required
- Rollback has been tested

==================================================
60. DEFINITION OF DONE
==================================================

A feature is not complete merely because a screen is visible.

A feature is complete only when:

1. Database design exists.
2. Migration exists.
3. Backend model exists.
4. Validation exists.
5. Authorization exists.
6. API exists.
7. API tests exist.
8. Flutter model exists.
9. Repository exists.
10. Local storage behavior exists where required.
11. User interface exists.
12. Loading state exists.
13. Empty state exists.
14. Error state exists.
15. Permission restrictions work.
16. Audit behavior works.
17. Business rules are tested.
18. Offline behavior is handled where applicable.
19. Documentation is updated.
20. The workflow has been manually verified.

==================================================
61. REQUIRED WORKING STYLE
==================================================

Follow this workflow for every phase:

Step 1:
Inspect the current repository and summarize the existing implementation.

Step 2:
Identify missing requirements, risks, and dependencies.

Step 3:
Create or update a task plan.

Step 4:
Present the exact implementation scope for the current phase.

Step 5:
Implement in small, reviewable units.

Step 6:
Run migrations, analysis, tests, and builds.

Step 7:
Fix all failures caused by your changes.

Step 8:
Provide a completion report.

Do not claim that tests passed unless you actually executed them.

Do not claim that a build succeeded unless you actually built it.

Do not use mocked dashboard numbers in completed features.

Do not skip backend validation because Flutter already validates a form.

Do not delete failing tests to obtain a passing test suite.

Do not replace complex business rules with placeholders without reporting the limitation.

==================================================
62. FIRST RESPONSE REQUIRED FROM YOU
==================================================

Before writing application code, respond with:

1. Your understanding of the product
2. Assumptions
3. Recommended architecture
4. Proposed Flutter structure
5. Proposed backend structure
6. Proposed database modules
7. Offline-sync strategy
8. Security strategy
9. Phase-by-phase implementation plan
10. Major risks
11. Questions that genuinely block implementation
12. Exact tasks for Phase 0 and Phase 1

Ask only questions that materially affect the architecture or business rules.

Do not ask unnecessary questions such as whether basic login is needed. It is already required.

After receiving approval, begin Phase 0 and Phase 1 only.