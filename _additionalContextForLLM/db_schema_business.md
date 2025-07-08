--- DB Business Schema: All Tables and Fields ---

          table_name          |     column_name      |        data_type         | is_nullable 
------------------------------+----------------------+--------------------------+-------------
 agent_role_bindings          | id                   | integer                  | NO
 agent_role_bindings          | role_id              | integer                  | NO
 agent_role_bindings          | user_id              | bigint                   | NO
 agent_role_bindings          | chat_id              | bigint                   | NO
 agent_role_bindings          | status               | smallint                 | NO
 agent_role_bindings          | interaction_mode     | smallint                 | NO
 agent_role_bindings          | activation_date      | timestamp with time zone | NO
 agent_role_bindings          | deactivation_date    | timestamp with time zone | YES
 derived_workflow_bridges     | id                   | integer                  | NO
 derived_workflow_bridges     | src_input_id         | integer                  | NO
 derived_workflow_bridges     | dst_chat_id          | bigint                   | NO
 derived_workflow_bridges     | dst_message_id       | integer                  | NO
 derived_workflow_states      | id                   | integer                  | NO
 derived_workflow_states      | resultant_workflow   | character varying        | NO
 derived_workflow_states      | inputs_id            | integer                  | YES
 derived_workflow_states      | in_state             | character varying        | NO
 inputs                       | id                   | integer                  | NO
 inputs                       | user_id              | bigint                   | NO
 inputs                       | details              | jsonb                    | NO
 inputs                       | chat_id              | bigint                   | NO
 inputs                       | interaction_mode     | smallint                 | NO
 inputs                       | input_type           | smallint                 | NO
 inputs                       | role_id              | integer                  | YES
 inputs                       | live_event_id        | integer                  | YES
 inputs                       | workflow_guid        | uuid                     | YES
 inputs                       | message_id           | integer                  | NO
 inputs                       | date                 | timestamp with time zone | NO
 live_event_series            | id                   | integer                  | NO
 live_event_series            | name                 | character varying        | NO
 live_event_series            | status               | smallint                 | NO
 live_event_venues            | id                   | integer                  | NO
 live_event_venues            | name                 | character varying        | NO
 live_event_venues            | status               | smallint                 | NO
 live_events                  | id                   | integer                  | NO
 live_events                  | name                 | character varying        | NO
 live_events                  | venue_id             | integer                  | NO
 live_events                  | live_event_series_id | integer                  | NO
 live_events                  | status               | smallint                 | NO
 live_events                  | start_date           | timestamp with time zone | NO
 live_events                  | end_date             | timestamp with time zone | NO
 roles                        | id                   | integer                  | NO
 roles                        | token                | character varying        | NO
 roles                        | status               | smallint                 | NO
 roles                        | user_id              | integer                  | NO
 roles                        | live_event_id        | integer                  | NO
 roles                        | role_type            | character varying        | NO
 roles_to_spheres_assignments | id                   | integer                  | NO
 roles_to_spheres_assignments | role_id              | integer                  | NO
 roles_to_spheres_assignments | sphere_id            | integer                  | NO
 roles_to_spheres_assignments | assigned_date        | timestamp with time zone | NO
 roles_to_spheres_assignments | unassigned_date      | timestamp with time zone | YES
 roles_to_spheres_assignments | details              | jsonb                    | NO
 roles_to_spheres_assignments | status               | smallint                 | NO
 spheres_of_action            | id                   | integer                  | NO
 spheres_of_action            | name                 | character varying        | NO
 spheres_of_action            | trade                | character varying        | NO
 spheres_of_action            | live_event_id        | integer                  | NO
 spheres_of_action            | details              | jsonb                    | NO
 spheres_of_action            | status               | smallint                 | NO
 users                        | id                   | integer                  | NO
 users                        | mobile               | character varying        | NO
 users                        | first_name           | character varying        | NO
 users                        | middle_name          | character varying        | YES
 users                        | last_name            | character varying        | NO
 users                        | email                | character varying        | YES
 users                        | status               | smallint                 | NO
 users                        | language_setting     | smallint                 | NO
 users                        | details              | jsonb                    | NO
 users_employment_history     | id                   | integer                  | NO
 users_employment_history     | user_id              | integer                  | NO
 users_employment_history     | vendor_id            | integer                  | NO
 users_employment_history     | details              | jsonb                    | NO
 users_employment_history     | status               | smallint                 | NO
 users_employment_history     | start_date           | timestamp with time zone | NO
 users_employment_history     | end_date             | timestamp with time zone | YES
 vendors                      | id                   | integer                  | NO
 vendors                      | name                 | character varying        | NO
 vendors                      | details              | jsonb                    | NO
 vendors                      | status               | smallint                 | NO
(79 rows)


--- DB Business Schema: Relationships ---

          table_name          |        column        | references_table  | references_column 
------------------------------+----------------------+-------------------+-------------------
 agent_role_bindings          | role_id              | roles             | id
 derived_workflow_bridges     | src_input_id         | inputs            | id
 derived_workflow_states      | inputs_id            | inputs            | id
 inputs                       | live_event_id        | live_events       | id
 inputs                       | role_id              | roles             | id
 live_events                  | venue_id             | live_event_venues | id
 live_events                  | live_event_series_id | live_event_series | id
 roles                        | user_id              | users             | id
 roles                        | live_event_id        | live_events       | id
 roles_to_spheres_assignments | role_id              | roles             | id
 roles_to_spheres_assignments | sphere_id            | spheres_of_action | id
 spheres_of_action            | live_event_id        | live_events       | id
 users_employment_history     | vendor_id            | vendors           | id
 users_employment_history     | user_id              | users             | id
(14 rows)

