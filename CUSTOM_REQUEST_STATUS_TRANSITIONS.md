# Custom request status transitions

`draft → submitted → viewed/needs_information/proposed/accepted/declined/expired/canceled`. Proposal acceptance atomically moves `proposed → converted_to_booking`; repeated acceptance returns the linked booking. Providers can respond only to an owned active request. Customers accept only their own live proposal. Recurrence is descriptive; conversion creates the first appointment only.
