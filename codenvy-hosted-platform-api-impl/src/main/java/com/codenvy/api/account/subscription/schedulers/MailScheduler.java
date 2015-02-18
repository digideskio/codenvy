/*
 * CODENVY CONFIDENTIAL
 * __________________
 *
 *  [2012] - [2015] Codenvy, S.A.
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Codenvy S.A. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Codenvy S.A.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Codenvy S.A..
 */
package com.codenvy.api.account.subscription.schedulers;

import com.codenvy.api.account.billing.BillingService;
import com.codenvy.api.account.billing.PaymentState;
import com.codenvy.api.account.impl.shared.dto.Charge;
import com.codenvy.api.account.impl.shared.dto.Invoice;
import com.codenvy.api.account.subscription.service.util.SubscriptionMailSender;
import com.codenvy.api.core.ApiException;
import com.codenvy.api.core.ServerException;
import com.codenvy.commons.lang.IoUtil;
import com.codenvy.commons.lang.Strings;
import com.codenvy.commons.schedule.ScheduleDelay;

import org.codenvy.mail.MailSenderClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.inject.Named;
import javax.inject.Singleton;
import javax.mail.MessagingException;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * TODO
 *
 * @author Sergii Leschenko
 */
@Singleton
public class MailScheduler {
    private static final Logger LOG = LoggerFactory.getLogger(MailScheduler.class);

    private static final int INVOICES_LIMIT = 50; //TODO mb make it configurable

    private final SubscriptionMailSender subscriptionMailSender;
    private final BillingService         billingService;
    private final MailSenderClient       mailSenderClient;
    private final String                 invoiceSubject;
    private final Double                 freeUsage;
    private final String                 invoiceNoPaymentSubject;
    private final String                 billingFailedSubject;
    private final String                 successfulChargeMailTemplate;
    private final String                 invoiceNoPaymentTemplate;
    private final String                 unsuccessfulChargeMailTemplate;
    private final double                 price;
    private final String                 billingAddress;

    @Inject
    public MailScheduler(SubscriptionMailSender subscriptionMailSender,
                         BillingService billingService,
                         MailSenderClient mailSenderClient,
                         @Named("billing.saas.free.gbh") Double freeUsage,
                         @Named("subscription.saas.mail.invoice.subject") String invoiceSubject,
                         @Named("subscription.saas.mail.invoice.no_payment.subject") String invoiceNoPaymentSubject,
                         @Named("subscription.saas.mail.billing.failed.subject") String billingFailedSubject,
                         @Named("subscription.saas.mail.template.success") String successfulChargeMailTemplate,
                         @Named("subscription.saas.mail.template.success.no_payment") String invoiceNoPaymentTemplate,
                         @Named("subscription.saas.mail.template.fail") String unsuccessfulChargeMailTemplate,
                         @Named("subscription.saas.price") double price,
                         @Named("subscription.saas.mail.address") String billingAddress) {

        this.billingService = billingService;
        this.subscriptionMailSender = subscriptionMailSender;
        this.freeUsage = freeUsage;
        this.invoiceSubject = invoiceSubject;
        this.invoiceNoPaymentSubject = invoiceNoPaymentSubject;
        this.billingFailedSubject = billingFailedSubject;
        this.successfulChargeMailTemplate = successfulChargeMailTemplate;
        this.invoiceNoPaymentTemplate = invoiceNoPaymentTemplate;
        this.unsuccessfulChargeMailTemplate = unsuccessfulChargeMailTemplate;
        this.mailSenderClient = mailSenderClient;
        this.billingAddress = billingAddress;
        this.price = price;
    }

    //TODO configure it
    @ScheduleDelay(initialDelay = 6,
                   delay = 60,
                   unit = TimeUnit.SECONDS)
    public void sendEmails() {
        try {
            List<Invoice> notSendInvoices;
            while ((notSendInvoices = billingService.getNotSendInvoices(INVOICES_LIMIT, 0)).size() != 0) {
                for (Invoice notSendInvoice : notSendInvoices) {
                    try {
                        sendMail(notSendInvoice);

                        billingService.markInvoiceAsSent(notSendInvoice.getId());
                    } catch (ApiException e) {
                        LOG.error("Can't send email", e);
                    }
                }
            }
        } catch (ServerException e) {
            LOG.error("Can't get not send invoices", e);//TODO
        }
    }

    private void sendMail(Invoice invoice) throws ServerException {
        String subject;
        String template;

        if (invoice.getTotal() > 0) {
            if (PaymentState.PAID_SUCCESSFULLY.getState().equals(invoice.getPaymentState())) {//TODO Add check receipt status
                subject = invoiceSubject;
                template = successfulChargeMailTemplate;
            } else {
                subject = billingFailedSubject;
                template = unsuccessfulChargeMailTemplate;
            }
        } else {
            subject = invoiceNoPaymentSubject;
            template = invoiceNoPaymentTemplate;
        }

        sendMailWithConsumption(invoice, subject, template);
    }

    //TODO Use template engines instead this method
    private void sendMailWithConsumption(Invoice invoice, String subject, String mailTemplate) throws ServerException {
        StringBuilder stringBuilder = new StringBuilder();

        for (Charge charge : invoice.getCharges()) {
            stringBuilder.append(charge.getServiceId()).append("</br>");

            stringBuilder.append("<table>");
            stringBuilder.append("<tr>");
            stringBuilder.append("<td>Free Amount</td>");
            stringBuilder.append("<td>").append(charge.getFreeAmount()).append("</td>");
            stringBuilder.append("</tr>");

            stringBuilder.append("<tr>");
            stringBuilder.append("<td>Paid Amount</td>");
            stringBuilder.append("<td>").append(charge.getPaidAmount()).append("</td>");
            stringBuilder.append("</tr>");

            stringBuilder.append("</table>");

            stringBuilder.append(charge.getServiceId()).append("</br>");

            stringBuilder.append("<table>");
            stringBuilder.append("<tr>");
            stringBuilder.append("<th>Id</th>");
            stringBuilder.append("<th>Resources</th>");
            stringBuilder.append("</tr>");

            long totalConsumption = 0;

            final Map<String, String> details = charge.getDetails();

            for (Map.Entry<String, String> entry : details.entrySet()) {
                stringBuilder.append("<tr><td>")
                             .append(entry.getKey())
                             .append("</td><td>")
                             .append(entry.getValue())
                             .append("</td></tr>");

                totalConsumption += Long.parseLong(entry.getValue());
            }

            stringBuilder.append("<tr><td></td>Total<td>")
                         .append(totalConsumption)
                         .append("</td></tr>");

            stringBuilder.append("</table>");
        }

        final HashMap<String, String> mailTemplateProperties = new HashMap<>();
        mailTemplateProperties.put("resource.consumption", stringBuilder.toString());
        mailTemplateProperties.put("resource.free", String.valueOf(freeUsage));
        mailTemplateProperties.put("resource.price", String.valueOf(price));
        mailTemplateProperties.put("resource.amount", String.valueOf(invoice.getTotal()));

        final List<String> accountOwnersEmails = subscriptionMailSender.getAccountOwnersEmails(invoice.getAccountId());
        try {
            mailSenderClient.sendMail(billingAddress,
                                      Strings.join(", ", accountOwnersEmails.toArray(new String[0])),
                                      null,
                                      subject,
                                      MediaType.TEXT_HTML,
                                      IoUtil.readAndCloseQuietly(IoUtil.getResource(mailTemplate)),
                                      mailTemplateProperties);
        } catch (IOException | MessagingException e) {
            LOG.error(e.getLocalizedMessage(), e);
        }
    }
}
