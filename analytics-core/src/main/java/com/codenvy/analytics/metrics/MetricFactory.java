/*
 *
 * CODENVY CONFIDENTIAL
 * ________________
 *
 * [2012] - [2013] Codenvy, S.A.
 * All Rights Reserved.
 * NOTICE: All information contained herein is, and remains
 * the property of Codenvy S.A. and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Codenvy S.A.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Codenvy S.A..
 */

package com.codenvy.analytics.metrics;

import java.util.concurrent.ConcurrentHashMap;

/** @author <a href="mailto:abazko@codenvy.com">Anatoliy Bazko</a> */
public class MetricFactory {

    private static ConcurrentHashMap<MetricType, Metric> metrics = new ConcurrentHashMap<>();

    /** Creates new metric or returns existed one. */
    public static Metric createMetric(MetricType metricType) {
        if (metrics.contains(metricType)) {
            return metrics.get(metricType);
        }

        Metric metric;
        switch (metricType) {
            case FILE_MANIPULATION:
                metric = new FileManipulationMetric();
                break;
            case TENANT_CREATED:
                metric = new TenantCreatedMetric();
                break;
            case TENANT_DESTROYED:
                metric = new TenantDestroyedMetric();
                break;
            case ACTIVE_USERS_SET:
                metric = new ActiveUsersSetMetric();
                break;
            case ACTIVE_USERS:
                metric = new ActiveUsersNumberMetric();
                break;
            case ACTIVE_WS_SET:
                metric = new ActiveWsSetMetric();
                break;
            case ACTIVE_WS:
                metric = new ActiveWsNumberMetric();
                break;
            case USER_REMOVED:
                metric = new UserRemovedMetric();
                break;
            case USER_CREATED:
                metric = new UserCreatedMetric();
                break;
            case TOTAL_USERS:
                metric = new TotalUsersMetric();
                break;
            case TOTAL_WORKSPACES:
                metric = new TotalWorkspacesMetric();
                break;
            case USER_SSO_LOGGED_IN:
                metric = new UserSSOLoggedInMetric();
                break;
            case USER_LOGIN_GITHUB:
                metric = new UserLoginGithubMetric();
                break;
            case USER_LOGIN_FORM:
                metric = new UserLoginFormMetric();
                break;
            case USER_LOGIN_GOOGLE:
                metric = new UserLoginGoogleMetric();
                break;
            case USER_LOGIN_TOTAL:
                metric = new UserLoginTotalMetric();
                break;
            case USER_LOGIN_GITHUB_PERCENT:
                metric = new UserLoginGithubPercentMetric();
                break;
            case USER_LOGIN_FORM_PERCENT:
                metric = new UserLoginFormPercentMetric();
                break;
            case USER_LOGIN_GOOGLE_PERCENT:
                metric = new UserLoginGooglePercentMetric();
                break;
            case USER_CODE_REFACTOR:
                metric = new UserCodeRefactorMetric();
                break;
            case USER_CODE_COMPLETE:
                metric = new UserCodeCompleteMetric();
                break;
            case BUILD_STARTED:
                metric = new BuildStartedMetric();
                break;
            case RUN_STARTED:
                metric = new RunStartedMetric();
                break;
            case DEBUG_STARTED:
                metric = new DebugStarted();
                break;
            case PRODUCT_USAGE_TIME_0_10:
                metric = new ProductUsageTime010Metric();
                break;
            case PRODUCT_USAGE_TIME_TOTAL:
                metric = new ProductUsageTimeTotalMetric();
                break;
            case PRODUCT_USAGE_TIME_10_60:
                metric = new ProductUsageTime1060Metric();
                break;
            case PRODUCT_USAGE_TIME_60_MORE:
                metric = new ProductUsageTime60MoreMetric();
                break;
            case PRODUCT_USAGE_SESSIONS:
                metric = new ProductUsageSessionsMetric();
                break;
            case PRODUCT_USAGE_SESSIONS_0_10:
                metric = new ProductUsageSessions010Metric();
                break;
            case PRODUCT_USAGE_SESSIONS_10_60:
                metric = new ProductUsageSessions1060Metric();
                break;
            case PRODUCT_USAGE_SESSIONS_60_MORE:
                metric = new ProductUsageSessions60MoreMetric();
                break;
            case PRODUCT_USAGE_SESSIONS_TOTAL:
                metric = new ProductUsageSessionsTotalMetric();
                break;
            case USER_INVITE:
                metric = new UserInviteMetric();
                break;
            case USER_INVITE_ACTIVE:
                metric = new UserInviteActiveMetric();
                break;
            case USER_ACCEPT_INVITE:
                metric = new UserAcceptInviteMetric();
                break;
            case USER_ACCEPT_INVITE_PERCENT:
                metric = new UserAcceptInvitePercentMetric();
                break;
            case USERS_SENT_INVITE_ONCE:
                metric = new UsersSentInviteOnceMetric();
                break;
            case USER_ADDED_TO_WORKSPACE:
                metric = new UserAddedToWsMetric();
                break;
            case USER_ADDED_TO_WORKSPACE_INVITE:
                metric = new UserAddedToWsInviteMetric();
                break;
            case PROJECT_CREATED:
                metric = new ProjectsCreatedMetric();
                break;
            case PROJECT_DESTROYED:
                metric = new ProjectDestroyedMetric();
                break;
            case TOTAL_PROJECTS:
                metric = new TotalProjectsMetric();
                break;
            case PROJECT_CREATED_TYPES:
                metric = new ProjectsCreatedTypesMetric();
                break;
            case PROJECT_CREATED_USER_ACTIVE:
                metric = new ProjectCreatedUserActiveMetric();
                break;
            case PROJECT_TYPE_JAR:
                metric = new ProjectCreatedTypeJarMetric();
                break;
            case PROJECT_TYPE_WAR:
                metric = new ProjectCreatedWarNumber();
                break;
            case PROJECT_TYPE_JSP:
                metric = new ProjectCreatedTypeJspMetric();
                break;
            case PROJECT_TYPE_SPRING:
                metric = new ProjectCreatedSpringMetric();
                break;
            case PROJECT_TYPE_PHP:
                metric = new ProjectCreatedPhpMetric();
                break;
            case PROJECT_TYPE_PYTHON:
                metric = new ProjectCreatedPythonMetric();
                break;
            case PROJECT_TYPE_JAVASCRIPT:
                metric = new ProjectCreatedJavaScriptMetric();
                break;
            case PROJECT_TYPE_RUBY:
                metric = new ProjectCreatedRubyMetric();
                break;
            case PROJECT_TYPE_MMP:
                metric = new ProjectCreatedMMPMetric();
                break;
            case PROJECT_TYPE_NODEJS:
                metric = new ProjectCreatedNodejsMetric();
                break;
            case PROJECT_TYPE_ANDROID:
                metric = new ProjectCreatedAndroidMetric();
                break;
            case PROJECT_TYPE_OTHERS:
                metric = new ProjectCreatedOthersMetric();
                break;
            case USERS_CREATED_PROJECT_ONCE:
                metric = new UsersCreatedProjectOnceMetric();
                break;
            case PROJECT_DEPLOYED_TYPES:
                metric = new ProjectDeployedTypesMetric();
                break;
            case PROJECT_PAAS_APPFOG:
                metric = new ProjectPaasAppfogMetric();
                break;
            case PROJECT_PAAS_AWS:
                metric = new ProjectPaasAwsMetric();
                break;
            case PROJECT_PAAS_CLOUDBEES:
                metric = new ProjectPaasCloudbeesMetric();
                break;
            case PROJECT_PAAS_CLOUDFOUNDRY:
                metric = new ProjectPaasCloudfoundryMetric();
                break;
            case PROJECT_PAAS_GAE:
                metric = new ProjectPaasGaeMetric();
                break;
            case PROJECT_PAAS_HEROKU:
                metric = new ProjectPaasHerokuMetric();
                break;
            case PROJECT_PAAS_OPENSHIFT:
                metric = new ProjectPaasOpenshiftMetric();
                break;
            case PROJECT_PAAS_TIER3:
                metric = new ProjectPaasTier3Metric();
                break;
            case PROJECT_PAAS_LOCAL:
                metric = new ProjectPaasLocalMetric();
                break;
            case USERS_SHELL_LAUNCHED_ONCE:
                metric = new UsersShellLaunchedOnceMetric();
                break;
            case USERS_BUILT_ONCE:
                metric = new UsersBuiltOnceMetric();
                break;
            case USERS_DEPLOYED_ONCE:
                metric = new UsersDeployedOnceMetric();
                break;
            case USERS_DEPLOYED_PAAS_ONCE:
                metric = new UsersDeployedPaasOnceMetric();
                break;
            case USER_BUILT:
                metric = new UserBuiltMetric();
                break;
            case USER_DEPLOY:
                metric = new UserDeployMetric();
                break;
            case ACTIVITY:
                metric = new ActivityMetric();
                break;
            case FACTORY_CREATED:
                metric = new FactoryCreatedMetric();
                break;
            case FACTORY_URL_ACCEPTED:
                metric = new FactoryUrlAcceptedMetric();
                break;
            case TEMPORARY_WORKSPACE_CREATED:
                metric = new TemporaryWorkspaceCreatedMetric();
                break;
            case FACTORY_SESSIONS_TYPES:
                metric = new FactorySessionsTypesMetric();
                break;
            case FACTORY_SESSIONS_AUTH:
                metric = new FactorySessionsAuthMetric();
                break;
            case FACTORY_SESSIONS_ANON:
                metric = new FactorySessionsAnonMetric();
                break;
            case FACTORY_SESSIONS:
                metric = new FactorySessionsMetric();
                break;
            case PRODUCT_USAGE_TIME_FACTORY:
                metric = new ProductUsageTimeFactoryMetric();
                break;
            case PRODUCT_USAGE_TIME_FACTORY_TOTAL:
                metric = new ProductUsageTimeFactoryTotalMetric();
                break;
            case PRODUCT_USAGE_FACTORY_SESSIONS_0_10:
                metric = new ProductUsageFactorySessions010Metric();
                break;
            case PRODUCT_USAGE_FACTORY_SESSIONS_10_MORE:
                metric = new ProductUsageFactorySessions10MoreMetric();
                break;
            case FACTORY_PROJECT_IMPORTED:
                metric = new FactoryProjectImportedMetric();
                break;
            case FACTORY_SESSIONS_ABAN:
                metric = new FactorySessionsAbanMetric();
                break;
            case FACTORY_SESSIONS_CONV:
                metric = new FactorySessionsConvMetric();
                break;
            case FACTORY_SESSIONS_AND_BUILT:
                metric = new FactorySessionsAndBuiltMetric();
                break;
            case FACTORY_SESSIONS_AND_RUN:
                metric = new FactorySessionsAndRunMetric();
                break;
            case FACTORY_SESSIONS_AND_DEPLOY:
                metric = new FactorySessionsAndDeployMetric();
                break;
            case FACTORY_SESSIONS_AND_RUN_PERCENT:
                metric = new FactorySessionsAndRunPercentMetric();
                break;
            case FACTORY_SESSIONS_AND_BUILT_PERCENT:
                metric = new FactorySessionsAndBuiltPercentMetric();
                break;
            case FACTORY_SESSIONS_AND_DEPLOY_PERCENT:
                metric = new FactorySessionsAndDeployPercentMetric();
                break;
            case JREBEL_USER_PROFILE_INFO:
                metric = new JrebelUserProfileInfoMetric();
                break;
            case PRODUCT_USAGE_TIME_USERS:
                metric = new ProductUsageTimeUsersMetric();
                break;
            case PRODUCT_USAGE_TIME_DOMAINS:
                metric = new ProductUsageTimeDomainsMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_1DAY:
                metric = new ProductUsageTimeTopUsers1DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_7DAY:
                metric = new ProductUsageTimeTopUsers7DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_30DAY:
                metric = new ProductUsageTimeTopUsers30DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_60DAY:
                metric = new ProductUsageTimeTopUsers60DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_90DAY:
                metric = new ProductUsageTimeTopUsers90DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_365DAY:
                metric = new ProductUsageTimeTopUsers365DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_USERS_BY_LIFETIME:
                metric = new ProductUsageTimeTopUsersLifeTimeDayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_1DAY:
                metric = new ProductUsageTimeTopDomains1DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_7DAY:
                metric = new ProductUsageTimeTopDomains7DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_30DAY:
                metric = new ProductUsageTimeTopDomains30DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_60DAY:
                metric = new ProductUsageTimeTopDomains60DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_90DAY:
                metric = new ProductUsageTimeTopDomains90DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_365DAY:
                metric = new ProductUsageTimeTopDomains365DayMetric();
                break;
            case PRODUCT_USAGE_TIME_TOP_DOMAINS_BY_LIFETIME:
                metric = new ProductUsageTimeTopDomainsLifeTimeDayMetric();
                break;
            // TODO


            case USER_PROFILE:
                metric = new UsersProfileMetric();
                break;
            case USER_PROFILE_FIRSTNAME:
                metric = new UsersProfileFirstNameMetric();
                break;
            case USER_PROFILE_LASTNAME:
                metric = new UsersProfileLastNameMetric();
                break;
            case USER_PROFILE_EMAIL:
                metric = new UsersProfileEmailMetric();
                break;
            case USER_PROFILE_COMPANY:
                metric = new UsersProfileCompanyMetric();
                break;
            case USER_PROFILE_PHONE:
                metric = new UsersProfilePhoneMetric();
                break;
//            case USERS_SEGMENT_ANALYSIS_CONDITION_1:
//                metric = new UsersSegmentAnalysisCondition1();
//                break;
//            case USERS_SEGMENT_ANALYSIS_CONDITION_2:
//                metric = new UsersSegmentAnalysisCondition2();
//                break;
//            case USERS_SEGMENT_ANALYSIS_CONDITION_3:
//                metric = new UsersSegmentAnalysisCondition3();
//                break;
            //. TODO
            case USERS_UPDATE_PROFILE_LIST:
                metric = new UsersUpdateProfileList();
                break;
            case USERS_COMPLETED_PROFILE:
                metric = new UsersCompletedProfile();
                break;
            default:
                throw new IllegalArgumentException("Unknown metric type " + metricType);
        }

        Metric currentValue = metrics.putIfAbsent(metricType, metric);

        if (currentValue != null) {
            return currentValue;
        } else {
            return metric;
        }
    }

    /** Creates new metric or returns existed one. */
    public static Metric createMetric(String name) {
        MetricType metricType = MetricType.valueOf(name.toUpperCase());
        return createMetric(metricType);
    }
}
