/*
 *  [2012] - [2016] Codenvy, S.A.
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
package com.codenvy.plugin.pullrequest.client.vcs.hosting;

import com.codenvy.plugin.pullrequest.client.vcs.VcsService;
import com.codenvy.plugin.pullrequest.client.vcs.VcsServiceProvider;
import com.google.inject.Singleton;

import org.eclipse.che.api.core.model.project.ProjectConfig;
import org.eclipse.che.api.git.shared.Remote;
import org.eclipse.che.api.promises.client.Function;
import org.eclipse.che.api.promises.client.FunctionException;
import org.eclipse.che.api.promises.client.Promise;
import org.eclipse.che.api.promises.client.js.JsPromiseError;
import org.eclipse.che.api.promises.client.js.Promises;

import javax.inject.Inject;
import java.util.List;
import java.util.Set;

/**
 * Provider for the {@link VcsHostingService}.
 *
 * @author Kevin Pollet
 * @author Yevhenii Voevodin
 */
@Singleton
public class VcsHostingServiceProvider {
    private static final String ORIGIN_REMOTE_NAME = "origin";

    private final VcsServiceProvider     vcsServiceProvider;
    private final Set<VcsHostingService> vcsHostingServices;

    @Inject
    public VcsHostingServiceProvider(final VcsServiceProvider vcsServiceProvider,
                                     final Set<VcsHostingService> vcsHostingServices) {
        this.vcsServiceProvider = vcsServiceProvider;
        this.vcsHostingServices = vcsHostingServices;
    }

    /**
     * Returns the dedicated {@link VcsHostingService} implementation for the {@link #ORIGIN_REMOTE_NAME origin} remote.
     *
     * @param project
     *         project used to find origin remote and extract VCS hosting service
     */
    public Promise<VcsHostingService> getVcsHostingService(final ProjectConfig project) {
        if (project == null) {
            return Promises.reject(JsPromiseError.create(new NoVcsHostingServiceImplementationException()));
        }
        final VcsService vcsService = vcsServiceProvider.getVcsService(project);
        if (vcsService == null) {
            return Promises.reject(JsPromiseError.create(new NoVcsHostingServiceImplementationException()));
        }
        return vcsService.listRemotes(project)
                         .then(new Function<List<Remote>, VcsHostingService>() {
                             @Override
                             public VcsHostingService apply(List<Remote> remotes) throws FunctionException {
                                 for (Remote remote : remotes) {
                                     if (ORIGIN_REMOTE_NAME.equals(remote.getName())) {
                                         for (final VcsHostingService hostingService : vcsHostingServices) {
                                             if (hostingService.isHostRemoteUrl(remote.getUrl())) {
                                                 return hostingService.init(remote.getUrl());
                                             }
                                         }
                                     }
                                 }
                                 throw new FunctionException(new NoVcsHostingServiceImplementationException());
                             }
                         });
    }
}
