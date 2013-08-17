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

package com.codenvy.analytics.scripts;

import com.codenvy.analytics.BaseTest;
import com.codenvy.analytics.metrics.MetricParameter;
import com.codenvy.analytics.metrics.Utils;
import com.codenvy.analytics.metrics.value.ListListStringValueData;
import com.codenvy.analytics.scripts.util.Event;
import com.codenvy.analytics.scripts.util.LogGenerator;

import org.testng.annotations.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.testng.AssertJUnit.assertEquals;

/** @author <a href="mailto:abazko@codenvy.com">Anatoliy Bazko</a> */
public class TestScriptUsersUpdateProfile extends BaseTest {

    @Test
    public void testExecute() throws Exception {
        List<Event> events = new ArrayList<Event>();
        events.add(Event.Builder.createUserUpdateProfile("user1@gmail.com", "f2", "l2", "company", "1", "1")
                        .withDate("2013-01-01").build());
        events.add(Event.Builder.createUserUpdateProfile("user2@gmail.com", "f2", "l2", "company", "1", "1")
                        .withDate("2013-01-01").build());
        events.add(Event.Builder.createUserUpdateProfile("user3@gmail.com", "f2", "l2", "company", "1", "")
                        .withDate("2013-01-01").build());
        events.add(Event.Builder.createUserUpdateProfile("use43@gmail.com", "f2", "l2", "company", "1", "null")
                        .withDate("2013-01-01").build());
        File log = LogGenerator.generateLog(events);

        Map<String, String> context = Utils.newContext();
        context.put(MetricParameter.RESULT_DIR.name(), BASE_DIR);
        context.put(MetricParameter.FROM_DATE.name(), "20130101");
        context.put(MetricParameter.TO_DATE.name(), "20130101");

        ListListStringValueData valueData =
                (ListListStringValueData)executeAndReturnResult(ScriptType.USERS_UPDATE_PROFILE, log, context);

        assertEquals(valueData.size(), 2);
    }
}
