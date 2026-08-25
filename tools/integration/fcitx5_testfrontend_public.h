/*
 * SPDX-FileCopyrightText: 2020 CSSlayer <wengxt@gmail.com>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Public test-frontend interface reproduced from Fcitx 5 for integration
 * testing. This header is not linked into the production addon.
 */
#ifndef CASSOTIS_FCITX5_TESTFRONTEND_PUBLIC_H
#define CASSOTIS_FCITX5_TESTFRONTEND_PUBLIC_H

#include <string>

#include <fcitx-utils/key.h>
#include <fcitx/addoninstance.h>
#include <fcitx/inputcontext.h>

FCITX_ADDON_DECLARE_FUNCTION(TestFrontend, createInputContext,
                             ICUUID(const std::string &));
FCITX_ADDON_DECLARE_FUNCTION(TestFrontend, destroyInputContext, void(ICUUID));
FCITX_ADDON_DECLARE_FUNCTION(TestFrontend, keyEvent,
                             void(ICUUID, const Key &, bool));
FCITX_ADDON_DECLARE_FUNCTION(TestFrontend, sendKeyEvent,
                             bool(ICUUID, const Key &, bool));
FCITX_ADDON_DECLARE_FUNCTION(TestFrontend, pushCommitExpectation,
                             void(std::string));

#endif
